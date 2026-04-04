import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:restic_movil/app/data/models/cashier_user_model.dart';
import 'package:restic_movil/app/data/models/terminal_model.dart';
import 'package:restic_movil/app/data/repositories/cashier_repository.dart';
import 'package:restic_movil/app/modules/cash_register/controllers/open_shift_controller.dart';
import 'package:flutter/material.dart';

class MockCashierRepository implements CashierRepository {
  bool failApiCall = false;
  bool isOpened = false;

  @override
  Future<List<CashierUser>> getAdminAndCashierUsers() async {
    if (failApiCall) throw Exception('API Error Users');
    return [
      CashierUser(
        id: 'u-1',
        username: 'ana.gomez',
        name: 'Ana',
        lastName: 'Gomez',
        email: 'ana@example.com',
        active: true,
        roles: ['CAJA'],
      ),
    ];
  }

  @override
  Future<List<Terminal>> getTerminals() async {
    if (failApiCall) throw Exception('API Error Terminals');
    return [
      Terminal(
        id: 't-1',
        code: 'CAJA1',
        name: 'Caja 1 - Principal',
        active: true,
      ),
    ];
  }

  @override
  Future<void> openShift({
    required String cashierId,
    required double initialAmount,
    required String terminalId,
    String? remarks,
  }) async {
    if (failApiCall) throw Exception('No se pudo abrir la caja');
    isOpened = true;
  }
  
  @override
  Future<Map<String, dynamic>> closeShift({
    required String cashierId,
    required double declaredCashAmount,
    String? remarks,
  }) async {
    return {"status": "closed"};
  }

  Future<void> registerExpense({required String cashierShiftId, required double amount, required String reason, required String observations}) async {}
}

void main() {
  group('Pruebas de Controller - OpenShiftController (Caja)', () {
    late OpenShiftController controller;
    late MockCashierRepository mockRepository;

    setUp(() {
      Get.reset();
      Get.testMode = true; // Habilitar test-mode en GetX
      mockRepository = MockCashierRepository();
    });

    testWidgets('Debe cargar usuarios y terminales exitosamente', (tester) async {
      controller = Get.put(OpenShiftController(mockRepository));
      
      await tester.pumpWidget(const GetMaterialApp(home: Scaffold(body: SizedBox())));
      
      // Permitimos que las micro-tareas de onReady y el Get.showOverlay finalicen
      await tester.pumpAndSettle();
      
      expect(controller.users.length, 1);
      expect(controller.users.first.fullName, 'Ana Gomez');
      expect(controller.terminals.length, 1);
      expect(controller.terminals.first.name, 'Caja 1 - Principal');
    });

    testWidgets('El formulario de Apertura de Caja debe fallar si initialAmount es 0', (tester) async {
      controller = Get.put(OpenShiftController(mockRepository));
      await tester.pumpWidget(const GetMaterialApp(home: Scaffold(body: SizedBox())));
      await tester.pumpAndSettle();
      
      // Arrange (Sets required fields ok but invalid initial amount)
      controller.form.control('cashierId').value = 'u-1';
      controller.form.control('terminalId').value = 't-1';
      controller.form.control('initialAmount').value = '0.00';
      
      // Act
      await controller.submit();
      
      // Assert API is NOT called
      expect(mockRepository.isOpened, false);
      expect(controller.form.control('initialAmount').hasErrors, true);
    });

    testWidgets('Debe consumir la API exitosamente para la Apertura de Caja si el formulario es válido', (tester) async {
      controller = Get.put(OpenShiftController(mockRepository));
      await tester.pumpWidget(const GetMaterialApp(home: Scaffold(body: SizedBox())));
      await tester.pumpAndSettle();
      
      // Mock navigation stack for Get.back()
      Get.routing.route = GetPageRoute(page: () => const Scaffold());
      
      // Arrange
      controller.form.control('cashierId').value = 'u-1';
      controller.form.control('terminalId').value = 't-1';
      controller.form.control('initialAmount').value = '250000.00'; // valid amount
      
      // Act
      await tester.runAsync(() async {
        await controller.submit();
        Get.closeAllSnackbars();
      });
      await tester.pumpWidget(const SizedBox());

      // Assert API WAS called successfully
      expect(mockRepository.isOpened, true);
    });
  });
}
