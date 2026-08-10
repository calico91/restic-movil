import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get/get.dart';
import 'package:stomp_dart_client/stomp_dart_client.dart';
import 'package:restic_movil/app/data/services/storage_service.dart';
import 'package:restic_movil/app/data/models/order_model.dart';

class WebSocketService extends GetxService {
  StompClient? _client;
  final StorageService _storageService = Get.find<StorageService>();

  /* Controlador de flujo para transmitir actualizaciones de órdenes individuales */
  final _ordersController = StreamController<OrderModel>.broadcast();
  Stream<OrderModel> get ordersStream => _ordersController.stream;

  /* Controlador de flujo para transmitir actualizaciones de la lista de órdenes abiertas */
  final _openOrdersController = StreamController<List<OrderModel>>.broadcast();
  Stream<List<OrderModel>> get openOrdersStream => _openOrdersController.stream;

  /* Controlador de flujo para transmitir cambios de estado de órdenes individuales (pago, anulación, etc.) */
  final _orderStatusController = StreamController<OrderModel>.broadcast();
  Stream<OrderModel> get orderStatusStream => _orderStatusController.stream;

  // URL del WebSocket se construirá dinámicamente usando StorageService

  Future<void> connect() async {
    if (_client != null) return;

    final branchId = await _storageService.getBranchId();

    if (branchId == null) {
      debugPrint("No branch ID found, cannot connect to WebSocket");
      return;
    }

    final serverUrl = await _storageService.getServerUrl();
    if (serverUrl == null || serverUrl.isEmpty) {
      debugPrint("No server URL found, cannot connect to WebSocket");
      return;
    }

    final String baseUrlStr = serverUrl.startsWith('http')
        ? serverUrl.replaceFirst('http', 'ws')
        : 'ws://$serverUrl';
    final String cleanUrl = baseUrlStr.endsWith('/')
        ? baseUrlStr.substring(0, baseUrlStr.length - 1)
        : baseUrlStr;
    final String socketUrl = '$cleanUrl/ws';

    /* Obtener credenciales para los headers de la conexión */
    final String apiKey = dotenv.env['APP_API_KEY'] ?? '';
    final String? token = await _storageService.getToken();
    final Map<String, String> authHeaders = {
      if (apiKey.isNotEmpty) 'X-App-Key': apiKey,
      if (token != null) 'Authorization': 'Bearer $token',
    };

    _client = StompClient(
      config: StompConfig(
        url: socketUrl,
        webSocketConnectHeaders: authHeaders,
        stompConnectHeaders: authHeaders,
        onConnect: (frame) => _onConnect(frame, branchId),
        beforeConnect: () async {
          debugPrint('Connecting to WebSocket...');
        },
        onWebSocketError: (dynamic error) {
          debugPrint('WebSocket error: $error');
          _client = null;
        },
        onStompError: (frame) => debugPrint('Stomp error: ${frame.body}'),
        onDisconnect: (frame) {
          debugPrint('Disconnected from WebSocket');
          _client = null;
        },
      ),
    );

    _client?.activate();
  }

  void _onConnect(StompFrame frame, String branchId) {
    debugPrint('Connected to WebSocket');

    // Diferir las suscripciones un microtask para que StompHandler
    // termine de actualizar su estado interno antes de llamar a subscribe.
    Future.microtask(() {
      _subscribe(branchId);
    });
  }

  void _subscribe(String branchId) {
    /* Suscribirse a nuevas órdenes */
    final createdDestination = '/topic/branch/$branchId/orders/created';
    debugPrint('Subscribing to $createdDestination');
    _client?.subscribe(
      destination: createdDestination,
      callback: (frame) {
        if (frame.body != null) {
          try {
            debugPrint('Received order: ${frame.body}');
            final Map<String, dynamic> json = jsonDecode(frame.body!);
            final order = OrderModel.fromJson(json);
            _ordersController.add(order);
          } catch (e) {
            debugPrint('Error parsing order: $e');
          }
        }
      },
    );

    /* Suscribirse a actualizaciones de la lista de órdenes abiertas */
    final openOrdersDestination = '/topic/branch/$branchId/orders/open';
    debugPrint('Subscribing to $openOrdersDestination');
    _client?.subscribe(
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

    /* Suscribirse a cambios de estado de órdenes (pago, anulación, etc.) */
    final statusDestination = '/topic/branch/$branchId/orders/status';
    debugPrint('Subscribing to $statusDestination');
    _client?.subscribe(
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

  void disconnect() {
    _client?.deactivate();
    _client = null;
  }
}
