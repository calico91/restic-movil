import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:restic_movil/app/data/models/sales_report_response.dart';
import 'package:restic_movil/app/data/models/shift_sales_report_response.dart';
import 'package:restic_movil/app/data/repositories/reports_repository.dart';
import 'package:restic_movil/app/modules/reports/controllers/reports_controller.dart';

// Mock del Repositorio de Reportes
class MockReportsRepository implements ReportsRepository {
  bool throwError = false;
  String? lastStartDate;
  String? lastEndDate;

  // Creamos un dummy de respuesta
  final SalesReportResponse dummyResponse = SalesReportResponse(
    startDate: '2026-04-01',
    endDate: '2026-04-04',
    totalTransactions: 12,
    totalSales: 540000.0,
    totalTips: 27000.0,
    grossRevenue: 567000.0,
    paymentBreakdown: [
      PaymentBreakdown(
        paymentMethod: 'CASH',
        description: 'Efectivo',
        totalAmount: 320000.0,
        transactionCount: 7,
        percentage: 59.26,
      )
    ],
    cashierSummary: [
      CashierSummary(
        cashierId: 'c8350e56-a52d-4d2d-9600-6cca7db94042',
        cashierName: 'Ana Gomez',
        transactionCount: 8,
        totalSales: 380000.0,
        totalTips: 19000.0,
      )
    ],
  );

  @override
  Future<SalesReportResponse> getSalesReport(String startDate, String endDate) async {
    lastStartDate = startDate;
    lastEndDate = endDate;

    if (throwError) {
      throw Exception('Error del servidor (HTTP 500)');
    }
    
    return dummyResponse;
  }

  @override
  Future<SalesReportResponse> getSalesReportByDateTime(String startDateTime, String endDateTime) async {
    if (throwError) throw Exception('Error del servidor (HTTP 500)');
    return dummyResponse;
  }

  @override
  Future<ShiftSalesReportResponse> getSalesReportByShiftId(String shiftId) async {
    if (throwError) throw Exception('Error del servidor (HTTP 500)');
    return ShiftSalesReportResponse(); // Retornamos objeto en blanco para compilación
  }

  @override
  Future<ShiftSalesReportResponse> getSalesReportByShiftDate(String openDate) async {
    if (throwError) throw Exception('Error del servidor (HTTP 500)');
    return ShiftSalesReportResponse(); // Retornamos objeto en blanco para compilación
  }
}

// Controlador de prueba que evita que onReady consuma el servicio automáticamente y crashee por falta de UI montada
class TestReportsController extends ReportsController {
  TestReportsController(super.repository);

  @override
  void onReady() {
    // Sobrescribimos onReady para evitar llamar a Get.showOverlay automáticamente al renderizar
    // Esto nos permite llamar manualmente a fetchSalesReport en las pruebas de manera controlada.
  }
}

void main() {
  group('Pruebas Unitarias - ReportsController (Consumo y API)', () {
    late TestReportsController controller;
    late MockReportsRepository mockRepository;

    setUp(() {
      Get.reset();
      Get.testMode = true; 
      mockRepository = MockReportsRepository();
    });

    testWidgets('El formateo de fechas hacia el endpoint (yyyy-MM-dd) debe ser estricto', (tester) async {
      await tester.pumpWidget(GetMaterialApp(home: Scaffold(body: Container())));
      controller = Get.put(TestReportsController(mockRepository));
      
      final date1 = DateTime(2026, 4, 4);
      final date2 = DateTime(2026, 4, 9);
      
      controller.setDates(date1, date2);

      // Usando await tester.runAsync resolverá los futures encolados
      await tester.runAsync(() async {
        await controller.fetchReport();
      });

      expect(mockRepository.lastStartDate, '2026-04-04', reason: 'El mes y el día deben tener cero a la izquierda');
      expect(mockRepository.lastEndDate, '2026-04-09');
    });

    testWidgets('Debe parsear y asignar correcta y reactivamente el JSON del reporte en caso de Exito (200 OK)', (tester) async {
      await tester.pumpWidget(GetMaterialApp(home: Scaffold(body: Container())));
      mockRepository.throwError = false;
      controller = Get.put(TestReportsController(mockRepository));

      await tester.runAsync(() async {
        await controller.fetchReport();
      });

      final report = controller.reportData.value;
      
      expect(report, isNotNull);
      expect(report!.totalSales, 540000.0);
      expect(report.totalTransactions, 12);
      
      expect(report.paymentBreakdown, isNotEmpty);
      expect(report.paymentBreakdown!.first.description, 'Efectivo');
      
      expect(report.cashierSummary, isNotEmpty);
      expect(report.cashierSummary!.first.cashierName, 'Ana Gomez');
      expect(report.cashierSummary!.first.totalTips, 19000.0);
    });

    testWidgets('Debe interceptar el error a nivel de controller de forma limpia y mantener el valor previo o nulo', (tester) async {
      await tester.pumpWidget(GetMaterialApp(home: Scaffold(body: Container())));
      mockRepository.throwError = true;
      Get.testMode = true;
      
      controller = Get.put(TestReportsController(mockRepository));

      await tester.runAsync(() async {
        await controller.fetchReport();
        // Cerramos el overlay activo o snackbar para evitar memory leaks the Tickeres en flutter_test
        Get.closeAllSnackbars();
      });

      // Asegurarse de quitar todos los widgets del virtual frame
      await tester.pumpWidget(const SizedBox());

      expect(controller.reportData.value, isNull);
    });
  });
}
