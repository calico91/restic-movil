import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:restic_movil/app/data/models/category_model.dart';
import 'package:restic_movil/app/data/models/order_item_model.dart';
import 'package:restic_movil/app/data/models/order_model.dart';
import 'package:restic_movil/app/data/repositories/categories_repository.dart';
import 'package:restic_movil/app/data/repositories/orders_repository.dart';
import 'package:restic_movil/app/data/services/storage_service.dart';
import 'package:restic_movil/app/modules/orders/views/widgets/add_products_sheet.dart';
import 'package:restic_movil/core/utils/animations/loading_charging.dart';
import 'package:restic_movil/core/utils/helpers/exception_handler.dart';
import 'package:restic_movil/core/utils/modals/modal_info.dart';
import 'package:restic_movil/core/utils/snackbars/error_snackbar.dart';
import 'package:restic_movil/core/utils/snackbars/info_snackbar.dart';

class OrdersController extends GetxController {
  final OrdersRepository ordersRepository;
  final CategoriesRepository categoriesRepository;
  final StorageService _storageService = Get.find<StorageService>();

  OrdersController({
    required this.ordersRepository,
    required this.categoriesRepository,
  });

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

  // Add Products Logic
  final RxList<CategoryModel> categories = <CategoryModel>[].obs;
  final RxList<OrderItemModel> tempAdditionalOrderItems =
      <OrderItemModel>[].obs;
  double get totalAdditionalAmount =>
      tempAdditionalOrderItems.fold(0, (sum, item) => sum + item.total);

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
      final savedDetailStatuses = await _storageService
          .getOrderDetailStatuses();

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

  /*filtrar pedidos por mesa o cliente*/
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
          
          // Buscar por nombre de cliente
          final customerName = order.customerName?.toLowerCase() ?? '';

          return tableNames.any((name) => name.contains(query)) ||
              orderNumber.contains(query) ||
              customerName.contains(query);
        }).toList(),
      );
    }
  }

  /* Cargar categorias */
  Future<void> _loadCategories() async {
    try {
      final result = await categoriesRepository.getCategories();
      categories.assignAll(result);
    } catch (e) {
      Get.showSnackbar(const ErrorSnackbar('Error al cargar productos'));
    }
  }

  /* Iniciar proceso de agregar productos */
  void startAddProducts(OrderModel order) {
    tempAdditionalOrderItems.clear();
    if (categories.isEmpty) {
      Get.showOverlay(
        loadingWidget: const LoadingCharging(),
        asyncFunction: () async => await _loadCategories(),
      );
    }
    _showAddProductsSheet(order);
  }

  void _showAddProductsSheet(OrderModel order) {
    Get.bottomSheet(
      AddProductsSheet(order: order),
      isScrollControlled: true,
    );
  }

  /* Manipulación de items temporales */
  void addToTempOrder(
    ProductModel product,
    int quantity,
    String? comment, {
    List<Map<String, String>>? comboSelections,
    double additionalPrice = 0,
  }) {
    final normalizedComment = (comment == null || comment.trim().isEmpty)
        ? null
        : comment.trim();
    
    // Check duplication logic:
    // If it's a combo, we might want to check if the combo selections are identical.
    // For simplicity, for combos we can just add a new item or implement deep comparison. 
    // Here I'll mimic take_order logic: separate combos if needed.
    
    int index = -1;
    if (comboSelections == null || comboSelections.isEmpty) {
      index = tempAdditionalOrderItems.indexWhere(
        (item) =>
            item.product.id == product.id &&
            item.comment == normalizedComment &&
            (item.comboSelections == null || item.comboSelections!.isEmpty),
      );
    }

    if (index != -1) {
      tempAdditionalOrderItems[index].quantity += quantity;
      tempAdditionalOrderItems.refresh();
    } else {
      tempAdditionalOrderItems.add(
        OrderItemModel(
          product: product,
          quantity: quantity,
          comment: normalizedComment,
          comboSelections: comboSelections,
          additionalPrice: additionalPrice,
        ),
      );
    }
  }

  /* Incrementar cantidad temporal de un producto */
  void incrementTempProduct(ProductModel product) {
    // Solo llama a esto si no es combo o si se maneja desde fuera
    addToTempOrder(product, 1, null);
  }

  /* Decrementar cantidad temporal de un producto */
  void decrementTempProduct(ProductModel product) {
    final index = tempAdditionalOrderItems.indexWhere(
      (item) =>
          item.product.id == product.id &&
          (item.comment == null || item.comment!.isEmpty),
    );

    if (index != -1) {
      if (tempAdditionalOrderItems[index].quantity > 1) {
        tempAdditionalOrderItems[index].quantity--;
        tempAdditionalOrderItems.refresh();
      } else {
        tempAdditionalOrderItems.removeAt(index);
      }
    }
  }

  /* Obtener cantidad temporal de un producto */
  int getTempProductQuantity(ProductModel product) {
    return tempAdditionalOrderItems
        .where((item) => item.product.id == product.id)
        .fold(0, (sum, item) => sum + item.quantity);
  }

  /* Confirmar adición de productos al pedido */
  Future<void> confirmAddProducts(OrderModel order) async {
    if (tempAdditionalOrderItems.isEmpty) return;

    final itemsToAdd = tempAdditionalOrderItems.map((item) {
      final detail = {
        'productId': item.product.id,
        'quantity': item.quantity,
        'observations': item.comment ?? '',
      };

      if (item.comboSelections != null && item.comboSelections!.isNotEmpty) {
        detail["comboSelections"] = item.comboSelections;
      }
      return detail;
    }).toList();

    Get.showOverlay(
      loadingWidget: const LoadingCharging(),
      asyncFunction: () async {
        try {
          await ordersRepository.addOrderItems(order.id!, itemsToAdd);

          Get.back(); 
          Get.back(); 

          Get.showSnackbar(
            const InfoSnackbar('Productos agregados correctamente'),
          );
          loadOrders(withOverlay: false);
        } catch (e) {
          final String errorMessage = ExceptionHandler.extractMessage(e);
          Get.showSnackbar(ErrorSnackbar(errorMessage));
        }
      },
    );
  }
}
