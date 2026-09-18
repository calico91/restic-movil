import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:stomp_dart_client/stomp_dart_client.dart';
import 'package:restic_movil/app/data/services/storage_service.dart';
import 'package:restic_movil/app/data/models/order_model.dart';
import 'package:restic_movil/core/config/app_config.dart';

enum WsConnectionState { disconnected, connecting, connected }

class WebSocketService extends GetxService with WidgetsBindingObserver {
  StompClient? _client;
  final StorageService _storageService = Get.find<StorageService>();

  final Rx<WsConnectionState> connectionState =
      WsConnectionState.disconnected.obs;

  final _ordersController = StreamController<OrderModel>.broadcast();
  Stream<OrderModel> get ordersStream => _ordersController.stream;

  final _openOrdersController = StreamController<List<OrderModel>>.broadcast();
  Stream<List<OrderModel>> get openOrdersStream => _openOrdersController.stream;

  final _orderStatusController = StreamController<OrderModel>.broadcast();
  Stream<OrderModel> get orderStatusStream => _orderStatusController.stream;

  static const List<int> _backoffSeconds = [1, 2, 5, 10, 30];
  static const int _maxRetries = 5;
  int _backoffIndex = 0;
  int _retryCount = 0;
  bool _inForeground = true;
  bool _connectedOnce = false;
  bool _connecting = false;
  Timer? _reconnectTimer;
  final Random _random = Random();
  bool _disposed = false;

  Future<void> connect() async {
    if (_disposed || !_inForeground) return;
    if (_client != null || _connecting) return;
    _connecting = true;
    try {
      if (!_connectedOnce) {
        WidgetsBinding.instance.addObserver(this);
        _connectedOnce = true;
      }

      final branchId = await _storageService.getBranchId();
      if (branchId == null || branchId.isEmpty) {
        debugPrint('No branch ID found, cannot connect to WebSocket');
        return;
      }
      final serverUrl = await _storageService.getServerUrl();
      if (serverUrl == null || serverUrl.isEmpty) {
        debugPrint('No server URL found, cannot connect to WebSocket');
        return;
      }

      /* Normalizar la URL: misma lógica que base_http_client (https por defecto si no tiene protocolo) */
      final String rawUrl = serverUrl.endsWith('/')
          ? serverUrl.substring(0, serverUrl.length - 1)
          : serverUrl;
      final String baseUrlStr =
          rawUrl.startsWith('http') ? rawUrl : 'https://$rawUrl';

      /* Construir URL con esquema WebSocket nativo:
       https → wss, http → ws. Railway termina TLS en el edge y reenvía
       el header Upgrade al backend, por lo que wss:// funciona correctamente. */
      final bool isSecure = baseUrlStr.startsWith('https');
      final String socketUrl = isSecure
          ? '${baseUrlStr.replaceFirst('https', 'wss')}/ws'
          : '${baseUrlStr.replaceFirst('http', 'ws')}/ws';

      final String apiKey = AppConfig.appApiKey;
      final String? token = await _storageService.getToken();
      final Map<String, String> authHeaders = {
        if (apiKey.isNotEmpty) 'X-App-Key': apiKey,
        if (token != null) 'Authorization': 'Bearer $token',
        'X-Branch-Id': branchId,
      };

      connectionState.value = WsConnectionState.connecting;

      /* Todos los callbacks capturan la instancia del cliente y la comparan con
         _client: los eventos de clientes huerfanos/zombies de intentos anteriores
         no deben cancelar la conexion actual ni programar reconexiones paralelas
         (evita rafagas de sockets duplicados). */
      /* onWebSocketDone cubre el cierre limpio del servidor (deploy): sin esto la
         conexion moria en silencio y la app no reconectaba hasta el siguiente resume. */
      StompClient? client;
      client = StompClient(
        config: StompConfig(
          url: socketUrl,
          useSockJS: false,
          reconnectDelay: Duration.zero,
          webSocketConnectHeaders: authHeaders,
          stompConnectHeaders: authHeaders,
          onConnect: (frame) {
            final connected = client;
            if (connected == null || !identical(connected, _client)) return;
            connectionState.value = WsConnectionState.connected;
            _backoffIndex = 0;
            _retryCount = 0;
            _onConnect(frame, branchId, connected);
          },
          beforeConnect: () async {
            connectionState.value = WsConnectionState.connecting;
            debugPrint('Connecting to WebSocket...');
          },
          onWebSocketError: (dynamic error) {
            final errored = client;
            if (errored == null || !identical(errored, _client)) return;
            debugPrint('WebSocket error: $error');
            _handleDisconnect(errored);
          },
          onStompError: (frame) {
            final errored = client;
            if (errored == null || !identical(errored, _client)) return;
            debugPrint('Stomp error: ${frame.body}');
            _handleDisconnect(errored);
          },
          onDisconnect: (frame) {
            final disconnected = client;
            if (disconnected == null || !identical(disconnected, _client)) {
              return;
            }
            debugPrint('Disconnected from WebSocket');
            _handleDisconnect(disconnected);
          },
          onWebSocketDone: () {
            final done = client;
            if (done == null || !identical(done, _client)) return;
            debugPrint('WebSocket connection closed by server');
            _handleDisconnect(done);
          },
        ),
      );

      final active = client;
      _client = active;
      active.activate();
    } finally {
      _connecting = false;
    }
  }

  void _handleDisconnect(StompClient client) {
    if (!identical(client, _client)) return;
    _client = null;
    client.deactivate();
    connectionState.value = WsConnectionState.disconnected;
    _scheduleReconnect();
  }

  void _onConnect(StompFrame frame, String branchId, StompClient client) {
    debugPrint('Connected to WebSocket');
    Future.microtask(() {
      if (!identical(client, _client)) {
        return;
      }
      _subscribe(branchId, client);
    });
  }

  void _subscribe(String branchId, StompClient client) {
    final createdDestination = '/topic/branch/$branchId/orders/created';
    debugPrint('Subscribing to $createdDestination');
    client.subscribe(
      destination: createdDestination,
      callback: (frame) {
        if (frame.body != null) {
          try {
            final Map<String, dynamic> json = jsonDecode(frame.body!);
            final order = OrderModel.fromJson(json);
            _ordersController.add(order);
          } catch (e) {
            debugPrint('Error parsing order: $e');
          }
        }
      },
    );

    final openOrdersDestination = '/topic/branch/$branchId/orders/open';
    debugPrint('Subscribing to $openOrdersDestination');
    client.subscribe(
      destination: openOrdersDestination,
      callback: (frame) {
        if (frame.body != null) {
          try {
            final List<dynamic> jsonList = jsonDecode(frame.body!);
            final orders = jsonList.map((j) => OrderModel.fromJson(j)).toList();
            _openOrdersController.add(orders);
          } catch (e) {
            debugPrint('Error parsing open orders list: $e');
          }
        }
      },
    );

    final statusDestination = '/topic/branch/$branchId/orders/status';
    debugPrint('Subscribing to $statusDestination');
    client.subscribe(
      destination: statusDestination,
      callback: (frame) {
        if (frame.body != null) {
          try {
            final Map<String, dynamic> json = jsonDecode(frame.body!);
            final order = OrderModel.fromJson(json);
            _orderStatusController.add(order);
          } catch (e) {
            debugPrint('Error parsing order status: $e');
          }
        }
      },
    );
  }

  void _scheduleReconnect() {
    if (_disposed || !_inForeground) return;

    if (_retryCount >= _maxRetries) {
      connectionState.value = WsConnectionState.disconnected;
      debugPrint(
          'WebSocket: maxima cantidad de reintentos alcanzada ($_maxRetries)');
      return;
    }

    _reconnectTimer?.cancel();
    if (_backoffIndex >= _backoffSeconds.length) {
      _backoffIndex = _backoffSeconds.length - 1;
    }
    final int baseSeconds = _backoffSeconds[_backoffIndex];
    final int jitter = _random.nextInt(1000);
    final Duration delay = Duration(milliseconds: baseSeconds * 1000 + jitter);
    _backoffIndex = (_backoffIndex + 1).clamp(0, _backoffSeconds.length - 1);
    _retryCount++;
    debugPrint('Reconnecting WebSocket in ${baseSeconds}s (+jitter) '
        '(intento $_retryCount/$_maxRetries)');
    _reconnectTimer = Timer(delay, connect);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      if (!_inForeground) {
        _inForeground = true;
        debugPrint('WebSocket: app en foreground, reanudando');
        if (_client == null) {
          _retryCount = 0;
          _backoffIndex = 0;
          connect();
        }
      }
    } else if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.detached) {
      if (_inForeground) {
        _inForeground = false;
        debugPrint('WebSocket: app en background, desconectando');
        _reconnectTimer?.cancel();
        _reconnectTimer = null;
        _client?.deactivate();
        _client = null;
        _connecting = false;
        connectionState.value = WsConnectionState.disconnected;
      }
    }
  }

  void disconnect() {
    _reconnectTimer?.cancel();
    _reconnectTimer = null;
    _client?.deactivate();
    _client = null;
    _connecting = false;
    connectionState.value = WsConnectionState.disconnected;
    if (_connectedOnce) {
      WidgetsBinding.instance.removeObserver(this);
      _connectedOnce = false;
    }
  }

  @override
  void onClose() {
    _disposed = true;
    disconnect();
    _ordersController.close();
    _openOrdersController.close();
    _orderStatusController.close();
    super.onClose();
  }
}
