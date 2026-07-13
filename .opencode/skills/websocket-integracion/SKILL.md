---
name: websocket-integracion
description: "Integrar comunicación en tiempo real vía STOMP WebSocket siguiendo el patrón existente de restic-movil: suscripciones a tópicos, streams reactivos y conexión con autenticación"
---

## Qué hace esta skill

Implementa o extiende la comunicación WebSocket usando STOMP:
- Conexión al servidor WebSocket con headers de autenticación
- Suscripción a tópicos STOMP por sucursal (`branchId`)
- Exposición de streams reactivos via `StreamController.broadcast()`
- Parseo de mensajes JSON a modelos del proyecto
- Integración con `GetxService` como ciclo de vida persistente

## Estructura de WebSocketService (existente)

```
lib/app/data/services/websocket_service.dart
```

## Template para agregar un nuevo tópico/suscripción

Agregar en `WebSocketService`:

```dart
// 1. StreamController para el nuevo tipo de datos
final _nuevoDatosController = StreamController<TipoModelo>.broadcast();
Stream<TipoModelo> get nuevoDatosStream => _nuevoDatosController.stream;

// 2. Suscripción en _subscribe()
void _subscribe(String branchId) {
  // ... suscripciones existentes ...

  final nuevoDestination = '/topic/branch/$branchId/<nuevo-topic>';
  debugPrint('Subscribing to $nuevoDestination');
  _client?.subscribe(
    destination: nuevoDestination,
    callback: (frame) {
      if (frame.body != null) {
        try {
          debugPrint('Received data: ${frame.body}');
          final Map<String, dynamic> json = jsonDecode(frame.body!);
          final data = TipoModelo.fromJson(json);
          _nuevoDatosController.add(data);
        } catch (e) {
          debugPrint('Error parsing data: $e');
        }
      }
    },
  );
}
```

## Template para consumir WebSocket en un Controller

```dart
import 'package:get/get.dart';
import 'package:restic_movil/app/data/services/websocket_service.dart';
import 'package:restic_movil/app/data/services/storage_service.dart';

class MiController extends GetxController {
  final WebSocketService _webSocketService = Get.find<WebSocketService>();
  final StorageService _storageService = Get.find<StorageService>();

  final RxList<Modelo> datos = <Modelo>[].obs;
  StreamSubscription? _subscription;

  @override
  void onInit() {
    super.onInit();
    _connectWebSocket();
  }

  @override
  void onClose() {
    _subscription?.cancel();
    super.onClose();
  }

  void _connectWebSocket() {
    _webSocketService.connect();
    _subscription = _webSocketService.<streamName>.listen((data) {
      // Actualizar estado reactivo
      datos.add(data);
    });
  }
}
```

## Patrón del código real (WebSocketService existente)

```dart
class WebSocketService extends GetxService {
  StompClient? _client;
  final StorageService _storageService = Get.find<StorageService>();

  final _ordersController = StreamController<OrderModel>.broadcast();
  Stream<OrderModel> get ordersStream => _ordersController.stream;

  final _openOrdersController = StreamController<List<OrderModel>>.broadcast();
  Stream<List<OrderModel>> get openOrdersStream => _openOrdersController.stream;

  Future<void> connect() async {
    final branchId = await _storageService.getBranchId();
    if (branchId == null) return;

    final serverUrl = await _storageService.getServerUrl();
    if (serverUrl == null || serverUrl.isEmpty) return;

    final String baseUrlStr = serverUrl.startsWith('http')
        ? serverUrl.replaceFirst('http', 'ws')
        : 'ws://$serverUrl';
    final String cleanUrl = baseUrlStr.endsWith('/')
        ? baseUrlStr.substring(0, baseUrlStr.length - 1)
        : baseUrlStr;
    final String socketUrl = '$cleanUrl/ws';

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
        beforeConnect: () => debugPrint('Connecting to WebSocket...'),
        onWebSocketError: (dynamic error) =>
            debugPrint('WebSocket error: $error'),
        onStompError: (frame) => debugPrint('Stomp error: ${frame.body}'),
        onDisconnect: (frame) => debugPrint('Disconnected from WebSocket'),
      ),
    );
    _client?.activate();
  }

  void _onConnect(StompFrame frame, String branchId) {
    debugPrint('Connected to WebSocket');
    Future.microtask(() => _subscribe(branchId));
  }

  void _subscribe(String branchId) {
    _client?.subscribe(
      destination: '/topic/branch/$branchId/orders/created',
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

    _client?.subscribe(
      destination: '/topic/branch/$branchId/orders/open',
      callback: (frame) {
        if (frame.body != null) {
          try {
            final List<dynamic> jsonList = jsonDecode(frame.body!);
            final orders =
                jsonList.map((j) => OrderModel.fromJson(j)).toList();
            _openOrdersController.add(orders);
          } catch (e) {
            debugPrint('Error parsing open orders list: $e');
          }
        }
      },
    );
  }

  void disconnect() {
    _client?.deactivate();
  }
}
```

## Reglas importantes

1. `WebSocketService` extiende `GetxService` (no `GetxController`) para persistencia
2. Usar `StreamController.broadcast()` para permitir múltiples oyentes
3. La URL se construye reemplazando `http://` → `ws://` y agregando `/ws`
4. Incluir siempre headers de autenticación (`X-App-Key`, `Authorization: Bearer`)
5. Manejar errores de parseo con try-catch para no interrumpir el stream
6. Cancelar suscripciones en `onClose()` del controller que consume
7. Los tópicos siguen el formato `/topic/branch/{branchId}/{entidad}/{accion}`
8. No conectar WebSocket si no hay `branchId` o `serverUrl`
