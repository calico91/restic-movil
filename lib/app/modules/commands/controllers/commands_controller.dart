import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:restic_movil/app/data/models/order_model.dart';
import 'package:restic_movil/app/data/repositories/orders_repository.dart';
import 'package:restic_movil/app/data/services/storage_service.dart';
import 'package:restic_movil/app/data/services/websocket_service.dart';
import 'package:restic_movil/core/utils/animations/loading_charging.dart';
import 'package:restic_movil/core/utils/helpers/exception_handler.dart';
import 'package:restic_movil/core/utils/modals/modal_info.dart';
import 'package:restic_movil/core/utils/snackbars/error_snackbar.dart';

class CommandsController extends GetxController {
  final OrdersRepository ordersRepository;
  final WebSocketService _webSocketService = Get.find<WebSocketService>();
  final StorageService _storageService = Get.find<StorageService>();

  // Tab Handling
  final RxInt currentTab = 0.obs; // 0: Open, 1: Finalized
  final RxList<OrderModel> orders = <OrderModel>[].obs;
  final RxList<OrderModel> finalizedOrders = <OrderModel>[].obs;

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
    await Future.wait([loadOrders(withOverlay: true), _loadStatuses()]);
  }

  /*cargar pedidos activos */
  Future<void> loadOrders({bool withOverlay = false}) async {
    // Si estamos en finalizados, cargar finalizados
    if (currentTab.value == 1) {
      await loadFinalizedOrders(withOverlay: withOverlay);
      return;
    }

    try {
      final result = await ordersRepository.getOrdersByStatuses(['OPEN']);
      orders.assignAll(result);
    } catch (e) {
      debugPrint('Error loading active orders: $e');
    }
  }

  /*cargar pedidos finalizados*/
  Future<void> loadFinalizedOrders({bool withOverlay = false}) async {
    try {
      final result = await ordersRepository.getOrdersByStatuses(['FINALIZED']);
      finalizedOrders.assignAll(result);
    } catch (e) {
      debugPrint('Error loading finalized orders: $e');
    }
  }

  /*cambiar tab*/
  void changeTab(int index) {
    currentTab.value = index;
    if (index == 0) {
      loadOrders(withOverlay: true);
    } else {
      loadFinalizedOrders(withOverlay: true);
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

      // Filtrar SERVED en este controlador (Cocina)
      orderStatuses.assignAll(
        orderStatuses.where((s) => s['name'] != 'PAID').toList(),
      );

      // Detail Statuses
      List<Map<String, dynamic>> details;
      final savedDetailStatuses = await _storageService
          .getOrderDetailStatuses();

      if (savedDetailStatuses != null && savedDetailStatuses.isNotEmpty) {
        details = List<Map<String, dynamic>>.from(savedDetailStatuses);
      } else {
        details = await ordersRepository.getOrderDetailStatuses();
        await _storageService.saveOrderDetailStatuses(details);
      }

      // Filtrar SERVED en este controlador (Cocina)
      orderDetailStatuses.assignAll(
        details.where((s) => s['name'] != 'SERVED').toList(),
      );
    } catch (e) {
      final String errorMessage = ExceptionHandler.extractMessage(e);
      Get.showSnackbar(ErrorSnackbar(errorMessage));
    }
  }

  /*obtener descripcion del estado */
  String getStatusDescription(String statusName) {
    final status = orderStatuses.firstWhereOrNull(
      (s) => s['name'] == statusName,
    );
    return status != null ? status['description'] : statusName;
  }

  /*obtener descripcion del estado de detalle */
  String getDetailStatusDescription(String statusName) {
    final status = orderDetailStatuses.firstWhereOrNull(
      (s) => s['name'] == statusName,
    );
    return status != null ? status['description'] : statusName;
  }

  /*actualizar estado de detalle de pedido */
  Future<void> updateDetailsStatus(
    List<Map<String, dynamic>> items,
    String status,
    String orderIdentifier,
  ) async {
    Get.showOverlay(
      loadingWidget: LoadingCharging(),
      asyncFunction: () async {
        try {
          await ordersRepository.updateOrderDetailsStatus(items, status);
          await loadOrders(); // Recargar ordenes
          Get.back(); // Cerrar modal de estado (si está abierto)
          Get.back(); // Cerrar modal de detalles

          // Mostrar modal éxito
          Get.dialog(
            ModalInfo(
              title: '¡Operación Exitosa!',
              message:
                  'Orden de pedido #$orderIdentifier se cambio a estado ${getDetailStatusDescription(status)} correctamente.',
              onClose: () => Get.back(),
            ),
          );
        } catch (e) {
          final String errorMessage = ExceptionHandler.extractMessage(e);
          Get.showSnackbar(ErrorSnackbar(errorMessage));
        }
      },
    );
  }

  /*conectar al websocket */
  void _connectWebSocket() {
    _webSocketService.connect();

    // Escuchar actualizaciones completas de ordenes abiertas
    _webSocketService.openOrdersStream.listen((updatedOrders) {
      // Solo actualizar si estamos en la pestaña de pedidos activos (0)
      if (currentTab.value == 0) {
        orders.assignAll(updatedOrders);
      }
    });

    // Mantener la escucha de nuevas ordenes individuales si se requiere notificar o añadir incrementalmente
    // en caso de que la lista completa no llegue siempre.
    // _webSocketService.ordersStream.listen((order) { ... });
  }

  @override
  void onClose() {
    _webSocketService.disconnect();
    super.onClose();
  }
}
