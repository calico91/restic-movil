import 'package:get/get.dart';
import 'package:reactive_forms/reactive_forms.dart';
import 'package:restic_movil/app/data/models/order_item_model.dart';
import 'package:restic_movil/app/data/models/origin_type.dart';
import 'package:restic_movil/app/data/models/table_model.dart';
import 'package:restic_movil/app/data/models/category_model.dart';
import 'package:restic_movil/app/data/repositories/categories_repository.dart';
import 'package:restic_movil/app/data/repositories/orders_repository.dart';
import 'package:restic_movil/app/data/repositories/tables_repository.dart';
import 'package:restic_movil/app/data/services/storage_service.dart';
import 'package:restic_movil/core/utils/animations/loading_charging.dart';
import 'package:restic_movil/core/utils/snackbars/error_snackbar.dart';
import 'package:restic_movil/core/utils/helpers/exception_handler.dart';

class TakeOrderController extends GetxController {
  final OrdersRepository ordersRepository;
  final TablesRepository tablesRepository;
  final CategoriesRepository categoriesRepository;
  final StorageService storageService;

  TakeOrderController({
    required this.ordersRepository,
    required this.tablesRepository,
    required this.categoriesRepository,
    required this.storageService,
  });

  final form = FormGroup({
    'origin': FormControl<String>(validators: [Validators.required]),
  });

  final RxList<OriginType> originTypes = <OriginType>[].obs;
  final RxList<TableModel> tables = <TableModel>[].obs;
  final RxList<CategoryModel> categories = <CategoryModel>[].obs;
  final RxList<String> selectedTableIds = <String>[].obs;
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
      } else {
        tables.clear();
        selectedTableIds.clear();
      }
    });
  }

  @override
  void onReady() {
    super.onReady();
    _loadInitialData();
  }

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
  void addToOrder(ProductModel product, int quantity, String? comment) {
    // Verificar si ya existe el producto con el mismo comentario
    final index = currentOrder.indexWhere(
      (item) => item.product.id == product.id && item.comment == comment,
    );

    if (index != -1) {
      currentOrder[index].quantity += quantity;
      currentOrder.refresh(); // Refresh list to update UI
    } else {
      currentOrder.add(
        OrderItemModel(product: product, quantity: quantity, comment: comment),
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
    }
  }

  /*obtener cantidad de producto en el pedido (solo sin comentarios para el contador simple)*/
  int getProductQuantity(ProductModel product) {
    final item = currentOrder.firstWhereOrNull(
      (item) =>
          item.product.id == product.id &&
          (item.comment == null || item.comment!.isEmpty),
    );
    return item?.quantity ?? 0;
  }

  void removeFromOrder(OrderItemModel item) {
    currentOrder.remove(item);
  }

  void goBack() {
    Get.back();
  }
}
