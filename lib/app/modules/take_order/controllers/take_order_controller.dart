import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:reactive_forms/reactive_forms.dart';
import 'package:restic_movil/app/data/models/customer_model.dart';
import 'package:restic_movil/app/data/models/order_item_model.dart';
import 'package:restic_movil/app/data/models/origin_type.dart';
import 'package:restic_movil/app/data/models/table_model.dart';
import 'package:restic_movil/app/data/models/category_model.dart';
import 'package:restic_movil/app/data/repositories/categories_repository.dart';
import 'package:restic_movil/app/data/repositories/customer_repository.dart';
import 'package:restic_movil/app/data/repositories/orders_repository.dart';
import 'package:restic_movil/app/data/repositories/tables_repository.dart';
import 'package:restic_movil/app/data/services/storage_service.dart';
import 'package:restic_movil/app/routes/app_routes.dart';
import 'package:restic_movil/app/modules/orders/controllers/orders_controller.dart';
import 'package:restic_movil/core/utils/animations/loading_charging.dart';
import 'package:restic_movil/core/utils/modals/modal_info.dart';
import 'package:restic_movil/core/utils/snackbars/error_snackbar.dart';
import 'package:restic_movil/core/utils/snackbars/info_snackbar.dart';
import 'package:restic_movil/core/utils/helpers/exception_handler.dart';

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

  double get totalOrderAmount =>
      currentOrder.fold(0, (sum, item) => sum + item.total);

  @override
  void onInit() {
    super.onInit();

    // Escuchar cambios en el origen
    form.control('origin').valueChanges.listen((value) {
      if (value == 'SALON') {
        _loadTables();
        selectedCustomer.value = null;
      } else if (value == 'TAKE_AWAY' || value == 'DELIVERY') {
        _fetchCustomers();
        tables.clear();
        selectedTableIds.clear();
      } else {
        tables.clear();
        selectedTableIds.clear();
        selectedCustomer.value = null;
      }
    });
  }

  @override
  void onReady() {
    super.onReady();
    _loadInitialData();
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
          final String errorMessage = ExceptionHandler.extractMessage(e);
          Get.showSnackbar(ErrorSnackbar(errorMessage));
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
          final String errorMessage = ExceptionHandler.extractMessage(e);
          Get.showSnackbar(ErrorSnackbar(errorMessage));
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
      Get.showSnackbar(
        ErrorSnackbar("No hay productos asociados al establecimiento."),
      );
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
            Get.showSnackbar(
              ErrorSnackbar(
                "No hay mesas disponibles para realizar un pedido.",
              ),
            );
          }
        } catch (e) {
          final String errorMessage = ExceptionHandler.extractMessage(e);
          Get.showSnackbar(ErrorSnackbar(errorMessage));
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

  /*agregar producto al pedido */
  void addToOrder(
    ProductModel product,
    int quantity,
    String? comment, {
    List<Map<String, String>>? comboSelections,
    double additionalPrice = 0,
  }) {
    // Normalizar comentario: tratar vacíos o solo espacios como null
    final normalizedComment = (comment == null || comment.trim().isEmpty)
        ? null
        : comment.trim();

    // Verificar si ya existe el producto con el mismo comentario
    // Para combos, si hay selecciones, por ahora no agrupamos para evitar complejidad
    // (o se podria implementar deep equality check)
    int index = -1;

    if (comboSelections == null || comboSelections.isEmpty) {
      index = currentOrder.indexWhere(
        (item) =>
            item.product.id == product.id &&
            item.comment == normalizedComment &&
            (item.comboSelections == null || item.comboSelections!.isEmpty),
      );
    }

    if (index != -1) {
      currentOrder[index].quantity += quantity;
      currentOrder.refresh(); // Refresh list to update UI
    } else {
      currentOrder.add(
        OrderItemModel(
          product: product,
          quantity: quantity,
          comment: normalizedComment,
          comboSelections: comboSelections,
          additionalPrice: additionalPrice,
        ),
      );
    }

    if (Get.isDialogOpen ?? false) {
      Get.back();
    }
  }

  /*incrementar cantidad de producto (sin comentarios)*/
  void incrementProduct(ProductModel product) {
    addToOrder(product, 1, null);
  }

  /*decrementar cantidad de producto (sin comentarios)*/
  void decrementProduct(ProductModel product) {
    // Busca items sin comentarios (productos estándar)
    final index = currentOrder.indexWhere(
      (item) =>
          item.product.id == product.id &&
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
  int getProductQuantity(ProductModel product) {
    return currentOrder
        .where((item) => item.product.id == product.id)
        .fold(0, (sum, item) => sum + item.quantity);
  }

  void removeFromOrder(OrderItemModel item) {
    currentOrder.remove(item);
  }

  void goBack() {
    Get.back();
  }

  /*crear nuevo pedido*/
  Future<void> createOrder() async {
    final origin = form.control('origin').value;

    // Validar si es SALON y no tiene mesas seleccionadas
    if (origin == 'SALON' && selectedTableIds.isEmpty) {
      Get.showSnackbar(
        const ErrorSnackbar('Debe seleccionar al menos una mesa'),
      );
      return;
    }

    // Validar cliente para otros origenes
    if ((origin == 'TAKE_AWAY' || origin == 'DELIVERY') &&
        selectedCustomer.value == null) {
      Get.showSnackbar(const ErrorSnackbar('Debe seleccionar un cliente'));
      return;
    }

    final Map<String, dynamic> orderData = {
      "details": currentOrder.map(
        (item) {
          final detail = {
            "productId": item.product.id,
            "quantity": item.quantity,
            "observations": item.comment ?? "",
          };

          if (item.comboSelections != null &&
              item.comboSelections!.isNotEmpty) {
            detail["comboSelections"] = item.comboSelections;
          }

          return detail;
        },
      ).toList(),
      "originType": origin,
      "observations": form.control('observations').value ?? "",
    };

    if (origin == 'SALON') {
      orderData["tableIds"] = selectedTableIds.toList();
    } else {
      orderData["customerId"] = selectedCustomer.value?.id;
    }

    Get.showOverlay(
      loadingWidget: const LoadingCharging(),
      asyncFunction: () async {
        try {
          await ordersRepository.createOrder(orderData);
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
            ModalInfo(
              title: 'Pedido Creado!',
              message: 'El pedido ha sido creado exitosamente.',
              icon: Icons.check_circle,
              buttonText: 'Ir a Pedidos',
              onClose: () {
                Get.until((route) => route.settings.name == Routes.HOME);
              },
              secondaryButtonText: 'Imprimir Orden',
              onSecondaryAction: () {
                // Aqu� ir�a la l�gica de impresi�n
                Get.showSnackbar(const InfoSnackbar('Enviando a imprimir...'));
              },
            ),
            barrierDismissible: false,
          );
        } catch (e) {
          final String errorMessage = ExceptionHandler.extractMessage(e);
          Get.showSnackbar(ErrorSnackbar(errorMessage));
        }
      },
    );
  }

  void _clearForm() {
    selectedTableIds.clear();
    selectedCustomer.value = null;
    currentOrder.clear();
    // Resetear el formulario completamnte, incluyendo el origen, dejandolo en null (estado inicial)
    form.reset();
  }
}
