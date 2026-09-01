import 'package:flutter_test/flutter_test.dart';
import 'package:restic_movil/app/data/models/product_sales_report_response.dart';

void main() {
  group('ProductSalesReportResponse.fromJson', () {
    test('parsea correctamente el reporte de productos seleccionados (sin eventos)', () {
      final json = {
        'startDateTime': '2026-04-22T08:00:00',
        'endDateTime': '2026-04-22T22:00:00',
        'generatedAt': '2026-04-22T20:05:00',
        'totalProducts': 1,
        'totalUnitsSold': 3,
        'totalRevenue': 36000.00,
        'products': [
          {
            'productId': 'p1',
            'productName': 'Hamburguesa',
            'productType': 'SIMPLE',
            'categoryName': 'Comidas',
            'subcategoryName': 'Hamburguesas',
            'timesSold': 2,
            'totalQuantity': 3,
            'totalRevenue': 36000.00,
          },
        ],
      };

      final response = ProductSalesReportResponse.fromJson(json);

      expect(response.startDateTime, DateTime(2026, 4, 22, 8, 0));
      expect(response.endDateTime, DateTime(2026, 4, 22, 22, 0));
      expect(response.generatedAt, DateTime(2026, 4, 22, 20, 5));
      expect(response.totalUnitsSold, 3);
      expect(response.totalRevenue, 36000.00);
      expect(response.products, hasLength(1));

      final summary = response.products!.first;
      expect(summary.productId, 'p1');
      expect(summary.productName, 'Hamburguesa');
      expect(summary.categoryName, 'Comidas');
      expect(summary.timesSold, 2);
      expect(summary.totalQuantity, 3);
      expect(summary.totalRevenue, 36000.00);
      expect(summary.percentage, isNull);
    });

    test('parsea correctamente el reporte de top-products con porcentaje', () {
      final json = {
        'startDateTime': '2026-04-22T00:00:00',
        'endDateTime': '2026-04-22T23:59:59',
        'generatedAt': '2026-04-22T20:00:00',
        'totalTransactions': 2,
        'totalProducts': 2,
        'totalUnitsSold': 10,
        'totalRevenue': 75000.00,
        'products': [
          {
            'productId': 'p1',
            'productName': 'Gaseosa',
            'categoryName': 'Bebidas',
            'subcategoryName': 'Gaseosas',
            'timesSold': 2,
            'totalQuantity': 5,
            'totalRevenue': 15000.00,
            'percentage': 50.0,
          },
        ],
      };

      final response = ProductSalesReportResponse.fromJson(json);

      expect(response.totalTransactions, 2);
      expect(response.products!.first.percentage, 50.0);
    });

    test('tolera campos opcionales faltantes y totales nulos', () {
      final response = ProductSalesReportResponse.fromJson({});

      expect(response.startDateTime, isNull);
      expect(response.totalUnitsSold, isNull);
      expect(response.totalRevenue, isNull);
      expect(response.products, isNull);
    });

    test('acepta enteros como String en campos numericos grandes', () {
      final json = {
        'totalProducts': '3',
        'totalUnitsSold': '100',
        'totalTransactions': '10',
        'products': [],
      };

      final response = ProductSalesReportResponse.fromJson(json);
      expect(response.totalProducts, 3);
      expect(response.totalUnitsSold, 100);
      expect(response.totalTransactions, 10);
    });
  });
}
