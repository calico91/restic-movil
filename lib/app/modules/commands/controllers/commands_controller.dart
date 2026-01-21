import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:restic_movil/app/data/models/order_model.dart';
import 'package:restic_movil/app/data/repositories/orders_repository.dart';
import 'package:restic_movil/app/data/services/websocket_service.dart';

class CommandsController extends GetxController {
  final OrdersRepository ordersRepository;
  final WebSocketService _webSocketService = Get.find<WebSocketService>();
  final RxList<OrderModel> orders = <OrderModel>[].obs;

  CommandsController({required this.ordersRepository});

  @override
  void onInit() {
    super.onInit();
    _loadInitialOrders();
    _connectWebSocket();
  }

  Future<void> _loadInitialOrders() async {
    try {
      final result = await ordersRepository.getOrdersByStatus('OPEN');
      // Ordenar por fecha: primero los más antiguos
      result.sort((a, b) {
        final dateA = DateTime.tryParse(a.openingDate ?? '') ?? DateTime.now();
        final dateB = DateTime.tryParse(b.openingDate ?? '') ?? DateTime.now();
        return dateA.compareTo(dateB);
      });
      orders.assignAll(result);
    } catch (e) {
      debugPrint('Error loading active orders: $e');
    }
  }

  void _connectWebSocket() {
    _webSocketService.connect();
    _webSocketService.ordersStream.listen((order) {
      // Agregar el nuevo pedido al final de la lista
      orders.add(order);
    });
  }

  @override
  void onClose() {
    _webSocketService.disconnect();
    super.onClose();
  }
}
