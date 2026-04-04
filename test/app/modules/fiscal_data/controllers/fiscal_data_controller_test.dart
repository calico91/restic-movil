import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:restic_movil/app/modules/fiscal_data/controllers/fiscal_data_controller.dart';
import 'package:restic_movil/app/data/repositories/fiscal_data_repository.dart';
import 'package:restic_movil/app/data/services/storage_service.dart';
import 'package:restic_movil/app/data/models/fiscal_data_model.dart';
import 'package:restic_movil/app/data/models/login_response.dart';

class MockFiscalDataRepository extends Fake implements FiscalDataRepository {
  Future<FiscalDataModel?> getFiscalDataByBranch(String branchId) async { return null; }
}

class MockStorageService extends StorageService {
  @override Future<String?> getBranchId() async => 'branch-1';
  Future<Map<String, dynamic>?> getFiscalData() async => null;
  @override Future<LoginResponse?> getUser() async => null;
}

void main() {
  group('FiscalDataController Test - Datos Fiscales', () {
    late FiscalDataController controller;
    
    setUp(() {
      Get.testMode = true;
      Get.reset();
      
      Get.put<StorageService>(MockStorageService());
      Get.put<FiscalDataRepository>(MockFiscalDataRepository());
    });

    testWidgets('Validación inicial del Reactive Form de datos fiscales', (tester) async {
       await tester.pumpWidget(const GetMaterialApp(home: Scaffold(body: SizedBox())));
       
       controller = FiscalDataController();
       Get.put(controller);
       
       await tester.runAsync(() async {
         await Future.delayed(const Duration(milliseconds: 100));
         Get.closeAllSnackbars();
       });
       await tester.pumpAndSettle();
       
      expect(controller.form.contains('businessName'), isTrue);
      expect(controller.form.contains('taxId'), isTrue);
      expect(controller.form.contains('address'), isTrue);
      expect(controller.form.contains('dianResolution'), isTrue);
    });
  });
}
