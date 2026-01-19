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
    currentOrder.add(
      OrderItemModel(product: product, quantity: quantity, comment: comment),
    );
    Get.back(); // Close dialog
  }

  void removeFromOrder(OrderItemModel item) {
    currentOrder.remove(item);
  }

  void goBack() {
    Get.back();
  }
}
