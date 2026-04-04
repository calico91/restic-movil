import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:restic_movil/app/modules/take_order/controllers/take_order_controller.dart';
import 'package:restic_movil/app/data/repositories/orders_repository.dart';
import 'package:restic_movil/app/data/repositories/tables_repository.dart';
import 'package:restic_movil/app/data/repositories/categories_repository.dart';
import 'package:restic_movil/app/data/repositories/customer_repository.dart';
import 'package:restic_movil/app/data/services/storage_service.dart';
import 'package:restic_movil/app/data/services/printer_service.dart';
import 'package:restic_movil/app/data/models/category_model.dart';
import 'package:restic_movil/app/data/models/customer_model.dart';
import 'package:restic_movil/app/data/models/table_model.dart';

class MockOrdersRepository extends Fake implements OrdersRepository {
  Future<List<Map<String, dynamic>>> getOrderOrigins() async => [
    {'id': 1, 'name': 'LOCAL'},
  ];
}

class MockTablesRepository extends Fake implements TablesRepository {
  Future<List<TableModel>> getTables() async => [];
}

class MockCategoriesRepository extends Fake implements CategoriesRepository {
  @override
  Future<List<CategoryModel>> getCategories() async => [];
}

class MockCustomerRepository extends Fake implements CustomerRepository {
  Future<List<CustomerModel>> getCustomers() async => [];
}

class MockStorageService extends StorageService {
  @override
  Future<List<dynamic>?> getOrderOrigins() async => null;
  @override
  Future<void> saveOrderOrigins(List<dynamic> origins) async {}
}

class MockPrinterService extends PrinterService {
  @override
  Future<void> initBluetooth() async {}
}

void main() {
  group('TakeOrderController Test - Toma de Pedido', () {
    late TakeOrderController controller;

    setUp(() {
      Get.testMode = true;
      Get.reset();

      Get.put<StorageService>(MockStorageService());
      Get.put<PrinterService>(MockPrinterService());

      controller = TakeOrderController(
        ordersRepository: MockOrdersRepository(),
        tablesRepository: MockTablesRepository(),
        categoriesRepository: MockCategoriesRepository(),
        customerRepository: MockCustomerRepository(),
        storageService: Get.find<StorageService>(),
      );
      Get.put(controller);
    });

    test('Validación inicial de la forma reactiva', () {
      expect(controller.form.contains('origin'), isTrue);
    });
  });
}
