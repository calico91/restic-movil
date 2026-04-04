import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:restic_movil/app/modules/orders/controllers/orders_controller.dart';
import 'package:restic_movil/app/data/repositories/orders_repository.dart';
import 'package:restic_movil/app/data/repositories/categories_repository.dart';
import 'package:restic_movil/app/data/services/storage_service.dart';
import 'package:restic_movil/app/data/services/websocket_service.dart';
import 'package:restic_movil/app/data/models/order_model.dart';
import 'package:restic_movil/app/data/models/category_model.dart';

class MockOrdersRepository extends Fake implements OrdersRepository {
  @override Future<List<OrderModel>> getOrdersByStatuses(List<String> statuses) async { return []; }
  @override Future<List<Map<String, dynamic>>> getOrderStatuses() async { return [{'id': 1, 'name': 'OPEN'}, {'id': 2, 'name': 'FINALIZED'}]; }
  @override Future<List<Map<String, dynamic>>> getOrderDetailStatuses() async { return []; }
}

class MockCategoriesRepository extends Fake implements CategoriesRepository {
  @override Future<List<CategoryModel>> getCategories() async { return []; }
}

class MockStorageService extends StorageService {
  @override Future<List<dynamic>?> getOrderStatuses() async => null;
  @override Future<void> saveOrderStatuses(List<dynamic> statuses) async {}
  @override Future<List<dynamic>?> getOrderDetailStatuses() async => null;
  @override Future<void> saveOrderDetailStatuses(List<dynamic> statuses) async {}
  @override
  Future<void> saveServerUrl(String url) async {}
  @override
  Future<String?> getServerUrl() async => "http://192.168.0.103:8093";
  @override
  Future<void> deleteServerUrl() async {}
}

class MockWebSocketService extends WebSocketService {
  @override Future<void> connect() async {}
  @override void disconnect() {}
  @override Stream<List<OrderModel>> get openOrdersStream => const Stream.empty();
  @override Stream<OrderModel> get ordersStream => const Stream.empty();
}

void main() {
  group('OrdersController Test', () {
    late OrdersController controller;
    setUp(() {
      Get.testMode = true;
      Get.put<StorageService>(MockStorageService());
      Get.put<WebSocketService>(MockWebSocketService());
      controller = OrdersController(
        ordersRepository: MockOrdersRepository(),
        categoriesRepository: MockCategoriesRepository(),
      );
      Get.put(controller);
    });
    tearDown(() { Get.reset(); });
    test('Cambio de Tab y Carga Inicial', () async {
      await controller.loadOrders(withOverlay: false);
      expect(controller.currentTab.value, 0);
      expect(controller.orders.length, 0);
    });
  });
}
