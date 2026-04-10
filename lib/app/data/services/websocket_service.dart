import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
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

  // URL del WebSocket se construirá dinámicamente usando StorageService

  Future<void> connect() async {
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

    final String baseUrlStr = serverUrl.startsWith('https')
        ? serverUrl.replaceFirst('https', 'ws')
        : 'ws://$serverUrl';
    final String cleanUrl = baseUrlStr.endsWith('/')
        ? baseUrlStr.substring(0, baseUrlStr.length - 1)
        : baseUrlStr;
    final String socketUrl = '$cleanUrl/ws';

    _client = StompClient(
      config: StompConfig(
        url: socketUrl,
        onConnect: (frame) => _onConnect(frame, branchId),
        beforeConnect: () async {
          debugPrint('Connecting to WebSocket...');
        },
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
  }

  void disconnect() {
    _client?.deactivate();
  }
}
