import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:restic_movil/app/data/models/terminal_model.dart';
import 'package:restic_movil/app/data/models/cashier_user_model.dart';
import 'package:restic_movil/app/data/models/login_response.dart';
import 'package:restic_movil/app/data/repositories/cashier_repository.dart';
import 'package:restic_movil/app/modules/cash_register/controllers/close_shift/close_shift_controller.dart';
import 'package:restic_movil/app/data/models/customer_model.dart';
import 'package:restic_movil/app/data/services/storage_service.dart';

class MockCashierRepository implements CashierRepository {
  bool isShiftClosed = false;

  @override
  Future<List<CashierUser>> getAdminAndCashierUsers() async => [];

  @override
  Future<List<Terminal>> getTerminals() async => [];

  @override
  Future<void> openShift({required String cashierId, required double initialAmount, required String terminalId, String? remarks}) async {}

  @override
  Future<Map<String, dynamic>> closeShift({required String cashierId, required double declaredCashAmount, String? remarks}) async {
    isShiftClosed = true;
    return {'status': 'OK'};
  }

  Future<void> registerExpense({required String cashierShiftId, required double amount, required String reason, required String observations}) async {}
}

class MockStorageService extends GetxService implements StorageService {
  @override
  Future<LoginResponse?> getUser() async {
    return LoginResponse(id: 'u-1', token: 'token', name: 'Admin', modules: []);
  }

  Never get storage => throw UnimplementedError();

  @override
  Future<void> deleteBranchId() async {}

  @override
  Future<void> deleteOrderDetailStatuses() async {}

  @override
  Future<void> deleteOrderOrigins() async {}

  @override
  Future<void> deleteOrderStatuses() async {}

  @override
  Future<void> deletePaymentMethods() async {}

  @override
  Future<void> deleteToken() async {}

  @override
  Future<void> deleteTransactionTypes() async {}

  @override
  Future<void> deleteUser() async {}

  @override
  Future<String?> getBranchId() async => '1';

  @override
  Future<List<String>?> getOrderDetailStatuses() async => [];

  @override
  Future<List<String>?> getOrderOrigins() async => [];

  @override
  Future<List<String>?> getOrderStatuses() async => [];

  @override
  Future<List<String>?> getPaymentMethods() async => [];

  @override
  Future<String?> getToken() async => 'token';

  @override
  Future<List<String>?> getTransactionTypes() async => [];

  Future<bool> hasToken() async => true;

  Future<bool> hasUser() async => true;

  @override
  Future<void> saveBranchId(String branchId) async {}

  @override
  Future<void> saveOrderDetailStatuses(List<dynamic> statuses) async {}

  @override
  Future<void> saveOrderOrigins(List<dynamic> origins) async {}

  @override
  Future<void> saveOrderStatuses(List<dynamic> statuses) async {}

  @override
  Future<void> savePaymentMethods(List<dynamic> paymentMethods) async {}

  @override
  Future<void> saveToken(String token) async {}

  @override
  Future<void> saveTransactionTypes(List<dynamic> types) async {}

  @override
  Future<void> saveUser(LoginResponse user) async {}

  @override
  Future<String?> getDefaultTipPercentage() async => null;

  @override
  Future<void> saveDefaultTipPercentage(String percentage) async {}

  @override
  Future<Map<String, String>?> getPrinterDevice() async => null;

  @override
  Future<void> savePrinterDevice(String name, String address) async {}

  Future<Map<String, dynamic>?> getFiscalData() async => null;

  Future<void> saveFiscalData(Map<String, dynamic> data) async {}

  Future<void> removeFiscalData() async {}
  @override
  Future<void> saveServerUrl(String url) async {}
  @override
  Future<String?> getServerUrl() async => "http://192.168.0.103:8093";
  @override
  Future<void> deleteServerUrl() async {}

  @override
  Future<void> saveDefaultCustomer(dynamic customer) async {}
  @override
  Future<CustomerModel?> getDefaultCustomer() async => null;
  @override
  Future<void> deleteDefaultCustomer() async {}

  @override
  Future<String> getPrinterSize() async => '58mm';

  @override
  Future<void> savePrinterSize(String size) async {}
}

void main() {
  group('Pruebas CloseShiftController (Cierre Caja)', () {
    late CloseShiftController controller;
    late MockCashierRepository mockRepository;
    late MockStorageService mockStorageService;

    setUp(() {
      Get.reset();
      Get.testMode = true;
      mockRepository = MockCashierRepository();
      mockStorageService = MockStorageService();

      Get.put<StorageService>(mockStorageService);
    });

    testWidgets('Debe retornar null y no cerrar caja si declaredAmount es vacío o invalido', (tester) async {
      await tester.pumpWidget(const GetMaterialApp(home: Scaffold(body: SizedBox())));
      controller = Get.put(CloseShiftController(cashierRepository: mockRepository));
      
      await tester.pumpAndSettle();
      
      controller.form.control('declaredCashAmount').value = '';

      Map<String, dynamic>? res;
      await tester.runAsync(() async {
        res = await controller.submitCloseShift();
        Get.closeAllSnackbars();
      });
      await tester.pumpWidget(const SizedBox());

      expect(res, isNull);
      expect(mockRepository.isShiftClosed, false);
    });

    testWidgets('Debe ejecutar el closure en repositorio cuando el payload es valido', (tester) async {
      await tester.pumpWidget(const GetMaterialApp(home: Scaffold(body: SizedBox())));
      controller = Get.put(CloseShiftController(cashierRepository: mockRepository));
      await tester.pumpAndSettle();

      controller.form.control('declaredCashAmount').value = '150,000.00';

      Map<String, dynamic>? res;
      await tester.runAsync(() async {
        res = await controller.submitCloseShift();
        Get.closeAllSnackbars();
      });
      await tester.pumpWidget(const SizedBox());

      expect(res, isNotNull);
      expect(res!['status'], 'OK');
      expect(mockRepository.isShiftClosed, true);
    });
  });
}

