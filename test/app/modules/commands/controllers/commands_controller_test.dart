import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:restic_movil/app/modules/commands/controllers/commands_controller.dart';
import 'package:restic_movil/app/data/repositories/orders_repository.dart';
import 'package:restic_movil/app/data/services/storage_service.dart';
import 'package:restic_movil/app/data/services/websocket_service.dart';
import 'package:restic_movil/app/data/models/order_model.dart';

class MockOrdersRepository extends Fake implements OrdersRepository {
  @override Future<List<OrderModel>> getOrdersByStatuses(List<String> statuses) async { return []; }
  @override Future<List<Map<String, dynamic>>> getOrderStatuses() async { return [{'name': 'OPEN'}, {'name': 'PREPARING'}]; }
  @override Future<List<Map<String, dynamic>>> getOrderDetailStatuses() async { return []; }
}

class MockStorageService extends StorageService {
  @override Future<List<dynamic>?> getOrderStatuses() async => null;
  @override Future<void> saveOrderStatuses(List<dynamic> statuses) async {}
  @override Future<List<dynamic>?> getOrderDetailStatuses() async => null;
  @override Future<void> saveOrderDetailStatuses(List<dynamic> statuses) async {}
}

class MockWebSocketService extends WebSocketService {
  @override Future<void> connect() async {}
  @override void disconnect() {}
  @override Stream<List<OrderModel>> get openOrdersStream => const Stream.empty();
  @override Stream<OrderModel> get ordersStream => const Stream.empty();
}

void main() {
  group('CommandsController Test', () {
    late CommandsController controller;
    setUp(() {
      Get.testMode = true;
      Get.put<StorageService>(MockStorageService());
      Get.put<WebSocketService>(MockWebSocketService());
      controller = CommandsController(ordersRepository: MockOrdersRepository());
      Get.put(controller);
    });
    tearDown(() { Get.reset(); });
    test('Cargar datos iniciales de comandos', () async {
      await controller.loadOrders(withOverlay: false);
      expect(controller.orders.length, 0);
    });
  });
}
