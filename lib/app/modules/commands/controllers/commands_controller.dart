import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:restic_movil/app/data/models/order_model.dart';
import 'package:restic_movil/app/data/repositories/orders_repository.dart';
import 'package:restic_movil/app/data/services/storage_service.dart';
import 'package:restic_movil/app/data/services/websocket_service.dart';

class CommandsController extends GetxController {
  final OrdersRepository ordersRepository;
  final WebSocketService _webSocketService = Get.find<WebSocketService>();
  final StorageService _storageService = Get.find<StorageService>();

  final RxList<OrderModel> orders = <OrderModel>[].obs;
  final RxList<Map<String, dynamic>> orderStatuses =
      <Map<String, dynamic>>[].obs;
  final RxList<Map<String, dynamic>> orderDetailStatuses =
      <Map<String, dynamic>>[].obs;

  CommandsController({required this.ordersRepository});

  @override
  void onInit() {
    super.onInit();
    _loadInitialData();
    _connectWebSocket();
  }

/*cargar datos iniciales */
  Future<void> _loadInitialData() async {
    await Future.wait([
      loadOrders(withOverlay: true),
      _loadStatuses(),
    ]);
  }

/*cargar pedidos activos */
  Future<void> loadOrders({bool withOverlay = false}) async {
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

/*cargar estados de pedidos y detalles */
  Future<void> _loadStatuses() async {
    try {
      // Order Statuses
      final savedStatuses = await _storageService.getOrderStatuses();
      if (savedStatuses != null && savedStatuses.isNotEmpty) {
        orderStatuses.assignAll(List<Map<String, dynamic>>.from(savedStatuses));
      } else {
        final fetched = await ordersRepository.getOrderStatuses();
        orderStatuses.assignAll(fetched);
        await _storageService.saveOrderStatuses(fetched);
      }

      // Detail Statuses
      final savedDetailStatuses =
          await _storageService.getOrderDetailStatuses();
      if (savedDetailStatuses != null && savedDetailStatuses.isNotEmpty) {
        orderDetailStatuses.assignAll(
          List<Map<String, dynamic>>.from(savedDetailStatuses),
        );
      } else {
        final fetched = await ordersRepository.getOrderDetailStatuses();
        orderDetailStatuses.assignAll(fetched);
        await _storageService.saveOrderDetailStatuses(fetched);
      }
    } catch (e) {
      debugPrint('Error loading statuses: $e');
    }
  }

/*obtener descripcion del estado */
  String getStatusDescription(String statusName) {
    final status = orderStatuses.firstWhereOrNull(
      (s) => s['name'] == statusName,
    );
    return status != null ? status['description'] : statusName;
  }

/*conectar al websocket */
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
