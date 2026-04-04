import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:restic_movil/app/modules/cash_register/controllers/cash_register_controller.dart';
import 'package:restic_movil/app/data/repositories/orders_repository.dart';
import 'package:restic_movil/app/data/repositories/payment_methods_repository.dart';
import 'package:restic_movil/app/data/repositories/transactions_repository.dart';
import 'package:restic_movil/app/data/services/storage_service.dart';
import 'package:restic_movil/app/data/services/websocket_service.dart';
import 'package:restic_movil/app/data/services/printer_service.dart';
import 'package:restic_movil/app/data/models/order_model.dart';
import 'package:restic_movil/app/data/models/payment_method_model.dart';
import 'package:restic_movil/app/data/models/transaction_type_model.dart';

class MockOrdersRepository extends Fake implements OrdersRepository {
  @override Future<List<OrderModel>> getOrdersByStatuses(List<String> statuses) async { return []; }
}
class MockPaymentMethodsRepository extends Fake implements PaymentMethodsRepository {
  @override Future<List<PaymentMethodModel>> getPaymentMethods() async { return []; }
}
class MockTransactionsRepository extends Fake implements TransactionsRepository {
  @override Future<List<TransactionTypeModel>> getTransactionTypes() async { return []; }
}
class MockStorageService extends StorageService {
  @override Future<String?> getDefaultTipPercentage() async => '10';
  @override Future<List<dynamic>?> getPaymentMethods() async => null;
  @override Future<void> savePaymentMethods(List<dynamic> methods) async {}
  @override Future<List<dynamic>?> getTransactionTypes() async => null;
  @override Future<void> saveTransactionTypes(List<dynamic> types) async {}
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
class MockPrinterService extends PrinterService {}

void main() {
  group('CashRegisterController Test', () {
    late CashRegisterController controller;
    setUp(() {
      WidgetsFlutterBinding.ensureInitialized();
      Get.testMode = true;
      Get.put<StorageService>(MockStorageService());
      Get.put<WebSocketService>(MockWebSocketService());
      Get.put<PrinterService>(MockPrinterService());
      controller = CashRegisterController(
        ordersRepository: MockOrdersRepository(),
        paymentMethodsRepository: MockPaymentMethodsRepository(),
        transactionsRepository: MockTransactionsRepository(),
      );
      Get.put(controller);
    });
    tearDown(() { Get.reset(); });
    test('Validar tabulado de Register', () async {
      await controller.loadPendingOrders(withOverlay: false);
      expect(controller.pendingOrders.length, 0);
    });
  });
}
