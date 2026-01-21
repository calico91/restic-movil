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

  // Stream controller to broadcast new orders
  final _ordersController = StreamController<OrderModel>.broadcast();
  Stream<OrderModel> get ordersStream => _ordersController.stream;

  // URL del WebSocket, asumiendo el puerto y path estándar basado en la URL de la API
  static const String _socketUrl = 'ws://192.168.101.8:8093/ws';

  Future<void> connect() async {
    final branchId = await _storageService.getBranchId();

    if (branchId == null) {
      debugPrint("No branch ID found, cannot connect to WebSocket");
      return;
    }

    _client = StompClient(
      config: StompConfig(
        url: _socketUrl,
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
    final destination = '/topic/branch/$branchId/orders/created';
    debugPrint('Subscribing to $destination');

    _client?.subscribe(
      destination: destination,
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
  }

  void disconnect() {
    _client?.deactivate();
  }
}
