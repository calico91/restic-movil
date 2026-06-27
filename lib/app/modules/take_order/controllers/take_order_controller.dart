import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:reactive_forms/reactive_forms.dart';
import 'package:restic_movil/app/data/models/customer_model.dart';
import 'package:restic_movil/app/data/models/order_item_model.dart';
import 'package:restic_movil/app/data/models/order_surcharge_model.dart';
import 'package:restic_movil/app/data/models/origin_type.dart';
import 'package:restic_movil/app/data/models/table_model.dart';
import 'package:restic_movil/app/data/models/category_model.dart';
import 'package:restic_movil/app/data/repositories/categories_repository.dart';
import 'package:restic_movil/app/data/repositories/customer_repository.dart';
import 'package:restic_movil/app/data/repositories/orders_repository.dart';
import 'package:restic_movil/app/data/repositories/tables_repository.dart';
import 'package:restic_movil/core/utils/modals/modal_warning.dart';
import 'package:restic_movil/core/utils/modals/order_success_modal.dart';
import 'package:restic_movil/app/data/services/storage_service.dart';
import 'package:restic_movil/app/routes/app_routes.dart';
import 'package:restic_movil/app/modules/orders/controllers/orders_controller.dart';
import 'package:restic_movil/core/utils/animations/loading_charging.dart';
import 'package:restic_movil/core/utils/helpers/error_handler.dart';
import 'package:restic_movil/app/modules/take_order/controllers/combo_selection_controller.dart';

class TakeOrderController extends GetxController {
  final OrdersRepository ordersRepository;
  final TablesRepository tablesRepository;
  final CategoriesRepository categoriesRepository;
  final CustomerRepository customerRepository;
  final StorageService storageService;

  TakeOrderController({
    required this.ordersRepository,
    required this.tablesRepository,
    required this.categoriesRepository,
    required this.customerRepository,
    required this.storageService,
  });

  final form = FormGroup({
    'origin': FormControl<String>(validators: [Validators.required]),
    'observations': FormControl<String>(value: ''),
  });

  final RxList<OriginType> originTypes = <OriginType>[].obs;
  final RxList<TableModel> tables = <TableModel>[].obs;
  final RxList<CategoryModel> categories = <CategoryModel>[].obs;
  final RxList<CustomerModel> customers = <CustomerModel>[].obs;
  final RxList<CustomerModel> filteredCustomers =
      <CustomerModel>[].obs; // Para busqueda
  final RxList<String> selectedTableIds = <String>[].obs;
  final Rxn<CustomerModel> selectedCustomer = Rxn<CustomerModel>();
  final RxList<OrderItemModel> currentOrder = <OrderItemModel>[].obs;
  final RxList<OrderSurchargeModel> surcharges = <OrderSurchargeModel>[].obs;
  final RxString searchProductQuery = ''.obs;
  final TextEditingController searchTextController = TextEditingController();

  /// Retorna las categorías filtrando los productos que son opciones de algún combo,
  /// para que no aparezcan en el menú principal de toma de pedidos.
  List<CategoryModel> get categoriesForDisplay {
    // Recolectar todos los productIds que son opciones de algún combo
    final Set<String> comboOptionIds = {};
    for (final CategoryModel cat in categories) {
      for (final sub in cat.subcategories ?? []) {
        for (final ProductModel p in sub.products ?? []) {
          for (final group in p.comboGroups ?? []) {
            for (final option in group.options ?? []) {
              if (option.productId != null) comboOptionIds.add(option.productId!);
            }
          }
        }
      }
    }

    // Reconstruir el árbol excluyendo esos productos
    final List<CategoryModel> filtered = [];
    for (final CategoryModel cat in categories) {
      final List<SubcategoryModel> filteredSubs = [];
      for (final sub in cat.subcategories ?? []) {
        final List<ProductModel> filteredProducts = (sub.products ?? [])
            .where((p) => p.id == null || !comboOptionIds.contains(p.id))
            .toList();
        if (filteredProducts.isNotEmpty) {
          filteredSubs.add(SubcategoryModel(
            id: sub.id,
            name: sub.name,
            description: sub.description,
            products: filteredProducts,
          ));
        }
      }
      if (filteredSubs.isNotEmpty) {
        filtered.add(CategoryModel(
          id: cat.id,
          name: cat.name,
          description: cat.description,
          printerIp: cat.printerIp,
          printerPort: cat.printerPort,
          subcategories: filteredSubs,
        ));
      }
    }
    return filtered;
  }

  /// Retorna los productos que coincidan con la búsqueda junto a su categoría y subcategoría.
  /// Solo incluye productos visibles en el menú (excluye opciones de combo).
  List<(ProductModel, String, String?)> get searchResults {
    if (searchProductQuery.isEmpty) return [];
    final String query = searchProductQuery.value.toLowerCase();
    final List<(ProductModel, String, String?)> results = [];
    for (final CategoryModel category in categoriesForDisplay) {
      final List subcategories = category.subcategories ?? [];
      for (final subcategory in subcategories) {
        for (final ProductModel product in subcategory.products ?? []) {
          if (product.name?.toLowerCase().contains(query) ?? false) {
            // Solo mostrar subcategoría si la categoría tiene más de una
            final String? subName =
                subcategories.length > 1 ? subcategory.name as String? : null;
            results.add((product, category.name ?? '', subName));
          }
        }
      }
    }
    return results;
  }

  /// Actualiza la consulta de búsqueda de productos.
  void onSearchProduct(String query) {
    searchProductQuery.value = query.trim().toLowerCase();
  }

  /// Limpia el campo y el estado de búsqueda de productos.
  void clearProductSearch() {
    searchTextController.clear();
    searchProductQuery.value = '';
  }

  double get totalOrderAmount {
    double detailsTotal = currentOrder.fold(0, (sum, item) => sum + item.total);
    double surchargesTotal = surcharges.fold(0, (sum, item) => sum + item.amount);
    return detailsTotal + surchargesTotal;
  }

  @override
  void onInit() {
    super.onInit();

    // Escuchar cambios en el origen
    form.control('origin').valueChanges.listen((value) {
      if (value != null) {
        _fetchCustomers();
        _applyDefaultCustomer();
      }

      if (value == 'SALON') {
        _loadTables();
      } else if (value == 'TAKE_AWAY' || value == 'DELIVERY') {
        tables.clear();
        selectedTableIds.clear();
      } else {
        tables.clear();
        selectedTableIds.clear();
        selectedCustomer.value = null;
      }
    });
  }

  /*carga y asigna automáticamente el cliente predeterminado si no hay uno seleccionado*/
  Future<void> _applyDefaultCustomer() async {
    if (selectedCustomer.value != null) return;
    final customer = await storageService.getDefaultCustomer();
    if (customer != null) {
      selectedCustomer.value = customer;
    }
  }

  @override
  void onReady() {
    super.onReady();
    _loadInitialData();
  }

  @override
  void onClose() {
    searchTextController.dispose();
    super.onClose();
  }

  /*cargar clientes de la api*/
  Future<void> _fetchCustomers() async {
    if (customers.isNotEmpty) return;

    Get.showOverlay(
      loadingWidget: const LoadingCharging(),
      asyncFunction: () async {
        try {
          final result = await customerRepository.getAllCustomers();
          customers.assignAll(result);
          filteredCustomers.assignAll(result);
        } catch (e) {
          ErrorHandler.showErrorDialog(e);
        }
      },
    );
  }

  /*filtrar clientes por nombre o telefono. La busqueda es case-insensitive 
  y permite coincidencias parciales.*/
  void searchCustomers(String query) {
    if (query.isEmpty) {
      filteredCustomers.assignAll(customers);
      return;
    }

    final lowerQuery = query.toLowerCase();
    filteredCustomers.assignAll(
      customers.where((customer) {
        return (customer.name?.toLowerCase().contains(lowerQuery) ?? false) ||
            (customer.phone?.contains(query) ?? false);
      }).toList(),
    );
  }

  /*seleccionar cliente para pedido take away o delivery*/
  void selectCustomer(CustomerModel customer) {
    selectedCustomer.value = customer;
  }

  /*cargar datos iniciales: origenes y categorias/productos. 
  Se hace en paralelo para optimizar tiempos. 
  Si falla alguna, se muestra el error pero se intenta cargar 
  la otra para no bloquear toda la pantalla*/
  Future<void> _loadInitialData() async {
    Get.showOverlay(
      loadingWidget: LoadingCharging(),
      asyncFunction: () async {
        try {
          await Future.wait([_fetchOriginTypes(), _fetchCategories()]);
        } catch (e) {
          ErrorHandler.showErrorDialog(e);
        }
      },
    );
  }

  /*consultar origen del pedido */
  Future<void> _fetchOriginTypes() async {
    final savedOrigins = await storageService.getOrderOrigins();

    if (savedOrigins != null && savedOrigins.isNotEmpty) {
      originTypes.assignAll(
        savedOrigins.map((e) => OriginType.fromJson(e)).toList(),
      );
    } else {
      final origins = await ordersRepository.getOriginTypes();
      originTypes.assignAll(origins);
      await storageService.saveOrderOrigins(
        origins.map((e) => e.toJson()).toList(),
      );
    }
  }

  /*consultar las categorias, subcategorias y productos */
  Future<void> _fetchCategories() async {
    final result = await categoriesRepository.getCategories();
          if (result.isEmpty) {
            ErrorHandler.showErrorDialog("No hay productos asociados al establecimiento.");
          }
    categories.assignAll(result);
  }

  /*consultar las mesas disponibles */
  Future<void> _loadTables() async {
    Get.showOverlay(
      loadingWidget: LoadingCharging(),
      asyncFunction: () async {
        try {
          final result = await tablesRepository.getAvailableTables();
          tables.assignAll(result);

          if (result.isEmpty) {
            ErrorHandler.showErrorDialog("No hay mesas disponibles para realizar un pedido.");
          }
        } catch (e) {
          ErrorHandler.showErrorDialog(e);
        }
      },
    );
  }

  /*seleccionar o deseleccionar mesa */
  void toggleTableSelection(String tableId) {
    if (selectedTableIds.contains(tableId)) {
      selectedTableIds.remove(tableId);
    } else {
      selectedTableIds.add(tableId);
    }
  }

  /*agregar producto al pedido; si se indica replaceItem, reemplaza ese item existente */
  OrderItemModel addToOrder(
    ProductModel product,
    int quantity,
    String? comment, {
    PriceModel? price,
    List<Map<String, String>>? comboSelections,
    double additionalPrice = 0,
    OrderItemModel? replaceItem,
  }) {
    // Normalizar comentario: tratar vacíos o solo espacios como null
    final String? normalizedComment = (comment == null || comment.trim().isEmpty)
        ? null
        : comment.trim();

    // Si se reemplaza un item existente (edición de combo), eliminarlo primero
    if (replaceItem != null) {
      currentOrder.remove(replaceItem);
    }

    // Agrupar con item existente solo para productos sin combo y sin reemplazo
    int index = -1;
    if ((comboSelections == null || comboSelections.isEmpty) && replaceItem == null) {
      index = currentOrder.indexWhere(
        (item) =>
            item.product.id == product.id &&
            item.selectedPrice?.id == price?.id &&
            item.comment == normalizedComment &&
            (item.comboSelections == null || item.comboSelections!.isEmpty),
      );
    }

    if (index != -1) {
      currentOrder[index].quantity += quantity;
      currentOrder.refresh();
      if (Get.isDialogOpen ?? false) Get.back();
      return currentOrder[index];
    } else {
      final OrderItemModel newItem = OrderItemModel(
        product: product,
        selectedPrice: price,
        quantity: quantity,
        comment: normalizedComment,
        comboSelections: comboSelections,
        additionalPrice: additionalPrice,
      );
      currentOrder.add(newItem);
      if (Get.isDialogOpen ?? false) Get.back();
      return newItem;
    }
  }

  /*incrementar cantidad de producto (sin comentarios)*/
  void incrementProduct(ProductModel product, PriceModel? price) {
    addToOrder(product, 1, null, price: price);
  }

  /*decrementar cantidad de producto (sin comentarios)*/
  void decrementProduct(ProductModel product, PriceModel? price) {
    // Busca items sin comentarios (productos estándar) con el mismo precio
    final index = currentOrder.indexWhere(
      (item) =>
          item.product.id == product.id &&
          item.selectedPrice?.id == price?.id &&
          (item.comment == null || item.comment!.isEmpty),
    );

    if (index != -1) {
      if (currentOrder[index].quantity > 1) {
        currentOrder[index].quantity--;
        currentOrder.refresh();
      } else {
        currentOrder.removeAt(index);
      }
    } else {
      // Opcional: Si se desea decrementar productos con notas, habria que decidir cuál quitar.
      // Por seguridad, aqui solo quitamos los que no tienen notas (agregados con +).
      // Si el usuario quiere quitar uno con notas, debe hacerlo desde el resumen.
    }
  }

  /*obtener cantidad de producto en el pedido (total, sin importar notas)*/
  int getProductQuantity(ProductModel product, PriceModel? price) {
    return currentOrder
        .where((item) => item.product.id == product.id && item.selectedPrice?.id == price?.id)
        .fold(0, (sum, item) => sum + item.quantity);
  }

  /*agregar una combinacion 2x1: determina el producto mas caro y lo registra con el acompañante*/
  void addCombination(ProductModel p1, ProductModel p2, int quantity, String? comment) {
    // Determinar cuál es el producto más caro (el que se cobra)
    final double price1 = p1.prices?.isNotEmpty == true ? (p1.prices!.first.amount ?? 0) : 0;
    final double price2 = p2.prices?.isNotEmpty == true ? (p2.prices!.first.amount ?? 0) : 0;
    final ProductModel expensive = price1 >= price2 ? p1 : p2;
    final ProductModel cheap = price1 >= price2 ? p2 : p1;
    final String? normalizedComment = (comment == null || comment.trim().isEmpty)
        ? null
        : comment.trim();

    // Solo agrupar si no tiene comentario; combinaciones con nota se tratan como ítems únicos
    final int index = normalizedComment == null
        ? currentOrder.indexWhere(
            (item) =>
                item.combinedWith != null &&
                item.product.id == expensive.id &&
                item.combinedWith!.id == cheap.id &&
                item.comment == null,
          )
        : -1;

    if (index != -1) {
      currentOrder[index].quantity += quantity;
      currentOrder.refresh();
    } else {
      currentOrder.add(
        OrderItemModel(
          product: expensive,
          quantity: quantity,
          combinedWith: cheap,
          comment: normalizedComment,
        ),
      );
    }

    if (Get.isDialogOpen ?? false) {
      Get.back();
    }
  }

  /*decrementar o eliminar una combinacion que incluya el producto indicado*/
  void decrementCombination(ProductModel product) {
    // Buscar la última combinación donde este producto es el expensive
    final int index = currentOrder.lastIndexWhere(
      (item) => item.combinedWith != null && item.product.id == product.id,
    );

    if (index != -1) {
      if (currentOrder[index].quantity > 1) {
        currentOrder[index].quantity--;
        currentOrder.refresh();
      } else {
        currentOrder.removeAt(index);
      }
    }
  }

  /*obtener la cantidad total de combinaciones activas donde el producto es el expensive*/
  int getCombinationQuantity(ProductModel product) {
    return currentOrder
        .where((item) => item.combinedWith != null && item.product.id == product.id)
        .fold(0, (sum, item) => sum + item.quantity);
  }

  /* Obtener todos los productos COMBINADO de la sucursal, excluyendo el producto actual */
  List<ProductModel> getCombinadoSiblings(ProductModel product) {
    final List<ProductModel> siblings = [];
    for (final CategoryModel category in categories) {
      for (final subcategory in category.subcategories ?? []) {
        for (final ProductModel p in subcategory.products ?? []) {
          if (p.productType == 'COMBINADO' && p.id != product.id) {
            siblings.add(p);
          }
        }
      }
    }
    return siblings;
  }
  // Agregar recargo al pedido
  void addSurcharge(String description, double amount) {
    surcharges.add(OrderSurchargeModel(description: description, amount: amount));
  }

  // Eliminar recargo por indice (podria ser por id si se asignan ids temporales)
  void removeSurcharge(int index) {
    if (index >= 0 && index < surcharges.length) {
      surcharges.removeAt(index);
    }
  }

  void removeFromOrder(OrderItemModel item) {
    currentOrder.remove(item);
  }

  /* Vuelve atrás; si hay productos en el pedido, solicita confirmación al usuario */
  void goBack() {
    if (currentOrder.isEmpty) {
      Get.back();
      return;
    }
    Get.dialog(
      ModalWarning(
        title: 'Salir sin completar',
        message: 'Tienes productos agregados al pedido. ¿Deseas salir y perder los cambios?',
        icon: Icons.shopping_cart_outlined,
        iconColor: Colors.orange,
        buttonText: 'Cancelar',
        secondaryButtonText: 'Salir',
        onSecondaryAction: () {
          Get.back(); // cierra el dialog
          Get.back(); // regresa a la pantalla anterior
        },
      ),
    );
  }

  /*crear nuevo pedido*/
  Future<void> createOrder() async {
    final origin = form.control('origin').value;

    // Validar si es SALON y no tiene mesas seleccionadas
    if (origin == 'SALON' && selectedTableIds.isEmpty) {
      ErrorHandler.showErrorDialog('Debe seleccionar al menos una mesa');
      return;
    }

    // Validar cliente para todos los origenes
    if (origin != null && selectedCustomer.value == null) {
      ErrorHandler.showErrorDialog('Debe seleccionar un cliente');
      return;
    }

    final Map<String, dynamic> orderData = {
      "details": currentOrder.map((item) {
        // Para COMBINADO: el nombre y las observaciones reflejan ambos platos
        final String productName = item.combinedWith != null
            ? '${item.productName} + ${item.combinedWith!.name ?? ""}'
            : item.productName;
        final String observations = item.combinedWith != null
            ? (item.comment != null && item.comment!.isNotEmpty
                ? 'COMBINADO: ${item.combinedWith!.name ?? ""} | ${item.comment}'
                : 'COMBINADO: ${item.combinedWith!.name ?? ""}')
            : (item.comment ?? '');

        final detail = {
          "productId": item.product.id,
          "selectedPriceId": item.selectedPrice?.id,
          "productName": productName,
          "quantity": item.quantity,
          "observations": observations,
        };

        if (item.comboSelections != null && item.comboSelections!.isNotEmpty) {
          detail["comboSelections"] = item.comboSelections;
        }

        return detail;
      }).toList(),
      "originType": origin,
      "observations": form.control('observations').value ?? "",
    };
    // Agregar recargos si existen
    if (surcharges.isNotEmpty) {
      orderData["surcharges"] = surcharges.map((s) => {
        "description": s.description,
        "amount": s.amount
      }).toList();
    }

    if (origin == 'SALON') {
      orderData["tableIds"] = selectedTableIds.toList();
    }
    
    orderData["customerId"] = selectedCustomer.value?.id;

    Get.showOverlay(
      loadingWidget: const LoadingCharging(),
      asyncFunction: () async {
        try {
          // Capturar snapshot de items y categorias antes de limpiar el formulario
          final List<OrderItemModel> orderItemsSnapshot = List.from(currentOrder);
          final List<CategoryModel> categoriesSnapshot = List.from(categories);

          final newOrder = await ordersRepository.createOrder(orderData);
          _clearForm();
          // Cerrar el resumen
          if (Get.isBottomSheetOpen ?? false) {
            Get.back();
          }

          // Actualizar lista de pedidos si el controlador existe
          if (Get.isRegistered<OrdersController>()) {
            Get.find<OrdersController>().loadOrders(withOverlay: false);
          }

          Get.dialog(
            OrderSuccessModal(
              title: 'Pedido Creado!',
              message: 'El pedido ha sido creado exitosamente.',
              order: newOrder,
              sourceItems: orderItemsSnapshot,
              categories: categoriesSnapshot,
              buttonText: 'Ir a Pedidos',
              onClose: () => Get.until((route) => route.settings.name == Routes.HOME),
            ),
            barrierDismissible: false,
          );
        } catch (e) {
          ErrorHandler.showErrorDialog(e);
        }
      },
    );
  }

  void _clearForm() {
    selectedTableIds.clear();
    selectedCustomer.value = null;
    currentOrder.clear();
    surcharges.clear();
    // Eliminar todos los controllers de combos persistidos
    ComboSelectionController.clearAll();
    // Resetear el formulario completamnte, incluyendo el origen, dejandolo en null (estado inicial)
    form.reset();
  }
}
