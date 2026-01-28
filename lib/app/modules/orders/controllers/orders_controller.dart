import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:restic_movil/app/data/models/order_model.dart';
import 'package:restic_movil/app/data/repositories/orders_repository.dart';
import 'package:restic_movil/app/data/services/storage_service.dart';
import 'package:restic_movil/core/utils/animations/loading_charging.dart';
import 'package:restic_movil/core/utils/helpers/exception_handler.dart';
import 'package:restic_movil/core/utils/modals/modal_info.dart';
import 'package:restic_movil/core/utils/snackbars/error_snackbar.dart';

class OrdersController extends GetxController {
  final OrdersRepository ordersRepository;
  final StorageService _storageService = Get.find<StorageService>();

  OrdersController({required this.ordersRepository});

  final RxList<OrderModel> _allOrders = <OrderModel>[].obs;
  final RxList<OrderModel> orders = <OrderModel>[].obs;
  
  // Tab Handling
  final RxInt currentTab = 0.obs; // 0: Open, 1: Finalized
  final RxList<OrderModel> _allFinalizedOrders = <OrderModel>[].obs;
  final RxList<OrderModel> finalizedOrders = <OrderModel>[].obs;

  final RxList<Map<String, dynamic>> orderStatuses =
      <Map<String, dynamic>>[].obs;
  final RxList<Map<String, dynamic>> orderDetailStatuses =
      <Map<String, dynamic>>[].obs;
  final searchController = TextEditingController();

  @override
  void onInit() {
    super.onInit();
    searchController.addListener(_filterOrders);
    _loadStatuses();
  }

  @override
  void onReady() {
    super.onReady();
    loadOrders();
  }

  @override
  void onClose() {
    searchController.dispose();
    super.onClose();
  }

  /*obtener pedidos en estado open*/
  Future<void> loadOrders({bool withOverlay = true}) async {
    // Si estamos en la pestaña de finalizados, cargamos finalizados
    if (currentTab.value == 1) {
      await loadFinalizedOrders(withOverlay: withOverlay);
      return;
    }

    Future<void> loadAction() async {
      try {
        final result = await ordersRepository.getOrdersByStatus('OPEN');
        _allOrders.assignAll(result);
        _filterOrders();
      } catch (e) {
        final String errorMessage = ExceptionHandler.extractMessage(e);
        Get.showSnackbar(ErrorSnackbar(errorMessage));
      }
    }

    if (withOverlay) {
      Get.showOverlay(
        loadingWidget: const LoadingCharging(),
        asyncFunction: loadAction,
      );
    } else {
      await loadAction();
    }
  }

  /*obtener pedidos finalizados*/
  Future<void> loadFinalizedOrders({bool withOverlay = true}) async {
    Future<void> loadAction() async {
      try {
        final result = await ordersRepository.getOrdersByStatus('FINALIZED');
        _allFinalizedOrders.assignAll(result);
        _filterOrders();
      } catch (e) {
        final String errorMessage = ExceptionHandler.extractMessage(e);
        Get.showSnackbar(ErrorSnackbar(errorMessage));
      }
    }

    if (withOverlay) {
      Get.showOverlay(
        loadingWidget: const LoadingCharging(),
        asyncFunction: loadAction,
      );
    } else {
      await loadAction();
    }
  }

  /*cambiar tab*/
  void changeTab(int index) {
    currentTab.value = index;
    searchController.clear();
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

      // Detail Statuses
      List<Map<String, dynamic>> details;
      final savedDetailStatuses = await _storageService.getOrderDetailStatuses();

      if (savedDetailStatuses != null && savedDetailStatuses.isNotEmpty) {
        details = List<Map<String, dynamic>>.from(savedDetailStatuses);
      } else {
        details = await ordersRepository.getOrderDetailStatuses();
        await _storageService.saveOrderDetailStatuses(details);
      }

      // Filtrar SERVED y ANULADO (CANCELED)
      orderDetailStatuses.assignAll(
        details
            .where((s) => s['name'] == 'SERVED' || s['name'] == 'CANCELED')
            .toList(),
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
    List<String> detailIds,
    String status,
    String orderIdentifier,
  ) async {
    Get.showOverlay(
      loadingWidget: const LoadingCharging(),
      asyncFunction: () async {
        try {
          await ordersRepository.updateOrderDetailsStatus(detailIds, status);
          await loadOrders(withOverlay: false); 
          Get.back(); // Cerrar bottom sheet
          Get.back(); // Cerrar modal detalle

          // Mostrar modal éxito
          Get.dialog(
            ModalInfo(
              title: '¡Operación Exitosa!',
              message:
                  'Pedido #$orderIdentifier se cambio a estado ${getDetailStatusDescription(status)} correctamente.',
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

  /*filtrar pedidos por mesa*/
  void _filterOrders() {
    final query = searchController.text.toLowerCase();
    
    // Determinar qué lista filtrar basada en el tab actual
    final sourceList = currentTab.value == 0 ? _allOrders : _allFinalizedOrders;
    final targetList = currentTab.value == 0 ? orders : finalizedOrders;

    if (query.isEmpty) {
      targetList.assignAll(sourceList);
    } else {
      targetList.assignAll(
        sourceList.where((order) {
          final tableNames =
              order.tables?.map((t) => t.name?.toLowerCase() ?? '').toList() ??
              [];
          // Busca si alguna mesa contiene el texto buscado
          // Tambien buscar por numero de orden
          final orderNumber = order.orderNumber?.toString() ?? '';
          return tableNames.any((name) => name.contains(query)) || orderNumber.contains(query);
        }).toList(),
      );
    }
  }
}
