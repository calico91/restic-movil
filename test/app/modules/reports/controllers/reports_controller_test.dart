import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:restic_movil/app/data/models/category_model.dart';
import 'package:restic_movil/app/data/models/product_sales_report_response.dart';
import 'package:restic_movil/app/data/models/sales_report_response.dart';
import 'package:restic_movil/app/data/models/shift_sales_report_response.dart';
import 'package:restic_movil/app/data/repositories/categories_repository.dart';
import 'package:restic_movil/app/data/repositories/reports_repository.dart';
import 'package:restic_movil/app/modules/reports/controllers/reports_controller.dart';

class MockReportsRepository implements ReportsRepository {
  bool throwError = false;
  String? lastStartDate;
  String? lastEndDate;
  String? lastProductStartDateTime;
  String? lastProductEndDateTime;
  List<String>? lastProductIds;

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
    return ShiftSalesReportResponse();
  }

  @override
  Future<ShiftSalesReportResponse> getSalesReportByShiftDate(String openDate) async {
    if (throwError) throw Exception('Error del servidor (HTTP 500)');
    return ShiftSalesReportResponse();
  }

  @override
  Future<ProductSalesReportResponse> getProductSalesReport(
    String startDateTime,
    String endDateTime,
    List<String> productIds,
  ) async {
    lastProductStartDateTime = startDateTime;
    lastProductEndDateTime = endDateTime;
    lastProductIds = List<String>.from(productIds);
    if (throwError) throw Exception('Error del servidor (HTTP 500)');
    return ProductSalesReportResponse(
      totalProducts: 2,
      totalUnitsSold: 6,
      totalRevenue: 45000.0,
      products: [
        ProductSalesSummary(
          productId: 'p1',
          productName: 'Hamburguesa',
          categoryName: 'Comidas',
          timesSold: 2,
          totalQuantity: 3,
          totalRevenue: 36000.0,
          events: [
            ProductSaleEvent(
              orderNumber: 101,
              soldAt: DateTime(2026, 4, 22, 12, 5),
              quantity: 1,
              unitPrice: 12000,
              subtotal: 12000,
            ),
          ],
        ),
      ],
    );
  }

  @override
  Future<ProductSalesReportResponse> getTopProductsReport(
    String startDateTime,
    String endDateTime,
  ) async {
    if (throwError) throw Exception('Error del servidor (HTTP 500)');
    return ProductSalesReportResponse(
      totalProducts: 1,
      totalUnitsSold: 3,
      totalRevenue: 36000,
      products: [
        ProductSalesSummary(
          productId: 'p1',
          productName: 'Hamburguesa',
          timesSold: 2,
          totalQuantity: 3,
          totalRevenue: 36000,
          percentage: 100.0,
        ),
      ],
    );
  }
}

class MockCategoriesRepository implements CategoriesRepository {
  List<CategoryModel> categories = const [];

  @override
  Future<List<CategoryModel>> getCategories() async {
    return categories;
  }

  @override
  noSuchMethod(Invocation invocation) {
    throw UnimplementedError();
  }
}

class TestReportsController extends ReportsController {
  TestReportsController(super.repository, super.categoriesRepository);

  @override
  void onReady() {
    // Evita llamadas automaticas al servicio durante los tests.
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
      controller = Get.put(TestReportsController(mockRepository, MockCategoriesRepository()));

      final date1 = DateTime(2026, 4, 4);
      final date2 = DateTime(2026, 4, 9);

      controller.setDates(date1, date2);

      await tester.runAsync(() async {
        await controller.fetchReport();
      });

      expect(mockRepository.lastStartDate, '2026-04-04');
      expect(mockRepository.lastEndDate, '2026-04-09');
    });

    testWidgets('Debe parsear y asignar correcta y reactivamente el JSON del reporte en caso de Exito', (tester) async {
      await tester.pumpWidget(GetMaterialApp(home: Scaffold(body: Container())));
      mockRepository.throwError = false;
      controller = Get.put(TestReportsController(mockRepository, MockCategoriesRepository()));

      await tester.runAsync(() async {
        await controller.fetchReport();
      });

      final report = controller.reportData.value;

      expect(report, isNotNull);
      expect(report!.totalSales, 540000.0);
      expect(report.totalTransactions, 12);
      expect(report.paymentBreakdown, isNotEmpty);
      expect(report.cashierSummary, isNotEmpty);
    });

    testWidgets('Debe interceptar el error a nivel de controller de forma limpia', (tester) async {
      await tester.pumpWidget(GetMaterialApp(home: Scaffold(body: Container())));
      mockRepository.throwError = true;
      Get.testMode = true;

      controller = Get.put(TestReportsController(mockRepository, MockCategoriesRepository()));

      await tester.runAsync(() async {
        await controller.fetchReport();
        Get.closeAllSnackbars();
      });

      await tester.pumpWidget(const SizedBox());

      expect(controller.reportData.value, isNull);
    });

    testWidgets('toggleProduct agrega y quita correctamente del set de seleccionados', (tester) async {
      await tester.pumpWidget(GetMaterialApp(home: Scaffold(body: Container())));
      controller = Get.put(TestReportsController(mockRepository, MockCategoriesRepository()));

      controller.toggleProduct('p1');
      expect(controller.selectedProductIds.contains('p1'), isTrue);

      controller.toggleProduct('p1');
      expect(controller.selectedProductIds.contains('p1'), isFalse);
    });

    testWidgets('clearProductSelection vacia la seleccion', (tester) async {
      await tester.pumpWidget(GetMaterialApp(home: Scaffold(body: Container())));
      controller = Get.put(TestReportsController(mockRepository, MockCategoriesRepository()));

      controller.toggleProduct('p1');
      controller.toggleProduct('p2');
      expect(controller.selectedProductIds.length, 2);

      controller.clearProductSelection();
      expect(controller.selectedProductIds, isEmpty);
    });

    testWidgets('fetchProductSalesReport exige minimo 1 producto seleccionado', (tester) async {
      await tester.pumpWidget(GetMaterialApp(home: Scaffold(body: Container())));
      controller = Get.put(TestReportsController(mockRepository, MockCategoriesRepository()));

      await tester.runAsync(() async {
        await controller.fetchProductSalesReport();
      });

      expect(mockRepository.lastProductIds, isNull);
      expect(controller.productReportData.value, isNull);
    });

    testWidgets('fetchProductSalesReport exitosa pasa datetime y productIds al repositorio', (tester) async {
      await tester.pumpWidget(GetMaterialApp(home: Scaffold(body: Container())));
      controller = Get.put(TestReportsController(mockRepository, MockCategoriesRepository()));

      controller.setDateTimes(
        DateTime(2026, 4, 22, 8, 0),
        DateTime(2026, 4, 22, 22, 0),
      );
      controller.toggleProduct('p1');
      controller.toggleProduct('p2');

      await tester.runAsync(() async {
        await controller.fetchProductSalesReport();
      });

      expect(controller.selectedProductIds.length, 2);
      expect(mockRepository.lastProductStartDateTime, '2026-04-22T08:00:00');
      expect(mockRepository.lastProductEndDateTime, '2026-04-22T22:00:00');
      expect(mockRepository.lastProductIds, ['p1', 'p2']);

      final data = controller.productReportData.value;
      expect(data, isNotNull);
      expect(data!.totalProducts, 2);
      expect(data.products!.first.events!.first.orderNumber, 101);
    });

    testWidgets('fetchTopProductsReport carga el ranking desde el repositorio', (tester) async {
      await tester.pumpWidget(GetMaterialApp(home: Scaffold(body: Container())));
      controller = Get.put(TestReportsController(mockRepository, MockCategoriesRepository()));

      controller.setDateTimes(
        DateTime(2026, 4, 22, 0, 0),
        DateTime(2026, 4, 22, 23, 59),
      );

      await tester.runAsync(() async {
        await controller.fetchTopProductsReport();
      });

      final data = controller.productReportData.value;
      expect(data, isNotNull);
      expect(data!.products!.first.percentage, 100.0);
    });
  });
}
