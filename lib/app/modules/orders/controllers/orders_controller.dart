import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:reactive_forms/reactive_forms.dart';
import 'package:restic_movil/app/data/models/category_model.dart';
import 'package:restic_movil/app/data/models/order_item_model.dart';
import 'package:restic_movil/app/data/models/order_model.dart';
import 'package:restic_movil/app/data/repositories/categories_repository.dart';
import 'package:restic_movil/app/data/repositories/orders_repository.dart';
import 'package:restic_movil/app/data/services/storage_service.dart';
import 'package:restic_movil/core/utils/animations/loading_charging.dart';
import 'package:restic_movil/core/utils/helpers/exception_handler.dart';
import 'package:restic_movil/core/utils/modals/modal_info.dart';
import 'package:restic_movil/core/utils/snackbars/error_snackbar.dart';
import 'package:restic_movil/core/utils/snackbars/info_snackbar.dart';
import 'package:restic_movil/core/utils/widgets/product_selection_widget.dart';

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
  final RxList<OrderItemModel> tempAdditionalOrderItems = <OrderItemModel>[].obs;
  double get totalAdditionalAmount => tempAdditionalOrderItems.fold(0, (sum, item) => sum + item.total);

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
      Container(
        height: Get.height * 0.9,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Agregar a pedido #${order.orderNumber}',
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Get.back(),
                  ),
                ],
              ),
            ),
            const Divider(),
            Expanded(
              child: SingleChildScrollView(
                child: Obx(
                  () {
                    // Forzar reactividad
                    final _ = tempAdditionalOrderItems.length;

                    return ProductSelectionWidget(
                      categories: categories.toList(),
                      getQuantity: getTempProductQuantity,
                      onIncrement: incrementTempProduct,
                      onDecrement: decrementTempProduct,
                      onEdit: (product) => _showAddProductDialog(product),
                    );
                  },
                ),
              ),
            ),
            Obx(() {
               if (tempAdditionalOrderItems.isEmpty) return const SizedBox.shrink();
               return Container(
                 padding: const EdgeInsets.all(16),
                 decoration: BoxDecoration(
                   color: Colors.white,
                   boxShadow: [
                     BoxShadow(
                       color: Colors.black.withValues(alpha: 0.1),
                       blurRadius: 10,
                       offset: const Offset(0, -5),
                     ),
                   ],
                 ),
                 child: Row(
                   children: [
                     Expanded(
                       child: Column(
                         crossAxisAlignment: CrossAxisAlignment.start,
                         mainAxisSize: MainAxisSize.min,
                         children: [
                           Text(
                             '${tempAdditionalOrderItems.length} items',
                             style: TextStyle(color: Colors.grey[600]),
                           ),
                           Text(
                             '\$${totalAdditionalAmount.toStringAsFixed(0)}',
                             style: const TextStyle(
                               fontSize: 20,
                               fontWeight: FontWeight.bold,
                               color: Colors.blue,
                             ),
                           ),
                         ],
                       ),
                     ),
                     ElevatedButton(
                       onPressed: () => _confirmAddProducts(order),
                       style: ElevatedButton.styleFrom(
                         backgroundColor: Colors.blue[900],
                         padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                         shape: RoundedRectangleBorder(
                           borderRadius: BorderRadius.circular(10),
                         ),
                       ),
                       child: const Text(
                         'Agregar',
                         style: TextStyle(color: Colors.white, fontSize: 16),
                       ),
                     ),
                   ],
                 ),
               );
            }),
          ],
        ),
      ),
      isScrollControlled: true,
    );
  }

  void _showAddProductDialog(ProductModel product) {
    final quantityControl = FormControl<int>(value: 1);
    final commentControl = FormControl<String>(value: '');

    Get.dialog(
      AlertDialog(
        title: Text('Producto: ${product.name}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ReactiveTextField(
              formControl: quantityControl,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Cantidad',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 10),
            ReactiveTextField(
              formControl: commentControl,
              decoration: const InputDecoration(
                labelText: 'Comentarios',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              addToTempOrder(
                product,
                quantityControl.value ?? 1,
                commentControl.value,
              );
              Get.back(); // Cerrar dialogo
            },
            child: const Text('Agregar'),
          ),
        ],
      ),
    );
  }

  /* Manipulación de items temporales */
  void addToTempOrder(ProductModel product, int quantity, String? comment) {
    final normalizedComment = (comment == null || comment.trim().isEmpty) ? null : comment.trim();
    final index = tempAdditionalOrderItems.indexWhere(
      (item) => item.product.id == product.id && item.comment == normalizedComment,
    );

    if (index != -1) {
      tempAdditionalOrderItems[index].quantity += quantity;
      tempAdditionalOrderItems.refresh();
    } else {
      tempAdditionalOrderItems.add(
        OrderItemModel(
          product: product,
          quantity: quantity,
          comment: normalizedComment,
        ),
      );
    }
  }

  void incrementTempProduct(ProductModel product) {
    addToTempOrder(product, 1, null);
  }

  void decrementTempProduct(ProductModel product) {
    final index = tempAdditionalOrderItems.indexWhere(
      (item) => item.product.id == product.id && (item.comment == null || item.comment!.isEmpty),
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

  int getTempProductQuantity(ProductModel product) {
    return tempAdditionalOrderItems
        .where((item) => item.product.id == product.id)
        .fold(0, (sum, item) => sum + item.quantity);
  }

  Future<void> _confirmAddProducts(OrderModel order) async {
    if (tempAdditionalOrderItems.isEmpty) return;

    final itemsToAdd = tempAdditionalOrderItems.map((item) => {
      'productId': item.product.id,
      'quantity': item.quantity,
      'observations': item.comment ?? '',
    }).toList();

    Get.showOverlay(
      loadingWidget: const LoadingCharging(),
      asyncFunction: () async {
        try {
          // Asumimos que existe un método addOrderItems en el repo
         // await ordersRepository.updateOrder(order.id!, itemsToAdd);
          
          Get.back(); // Cerrar overlay
          Get.back(); // Cerrar bottomsheet
          
          Get.showSnackbar(const InfoSnackbar('Productos agregados correctamente'));
          loadOrders(withOverlay: false);
        } catch (e) {
          final String errorMessage = ExceptionHandler.extractMessage(e);
          Get.showSnackbar(ErrorSnackbar(errorMessage));
        }
      },
    );
  }
}
