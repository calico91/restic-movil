import 'package:flutter_test/flutter_test.dart';
import 'package:restic_movil/app/data/models/annulled_orders_report_response.dart';

void main() {
  group('AnnulledOrdersReportResponse.fromJson', () {
    test('parsea correctamente un reporte con items de tipo PAID_SALE y PRE_PAID', () {
      final json = {
        'startDateTime': '2026-04-22T08:00:00',
        'endDateTime': '2026-04-22T22:00:00',
        'generatedAt': '2026-04-22T20:00:00',
        'totalOrders': 2,
        'totalPaidAnnulled': 1,
        'totalPrePaidCancelled': 1,
        'totalValue': 45000.00,
        'totalTipAmount': 3000.00,
        'items': [
          {
            'cancellationType': 'PAID_SALE',
            'transactionId': 't1',
            'transactionNumber': 'TXN-20260422130000-000001',
            'orderId': 'a1',
            'orderNumber': 101,
            'originType': 'Salón',
            'customerName': 'Maria Lopez',
            'waiterName': 'Juan Perez',
            'cancelledByName': 'Admin Root',
            'cancellationReason': 'Cliente cambio de opinion',
            'cancelledAt': '2026-04-22T13:05:00',
            'totalValue': 30000.00,
            'tipAmount': 3000.00,
            'change': 0.00,
            'shiftNumber': 'CAJA-01-20260422-001',
            'cashierName': 'Cajero Uno',
            'paymentMethods': [
              {'paymentMethod': 'CASH', 'amount': 33000.00}
            ],
          },
          {
            'cancellationType': 'PRE_PAID',
            'orderId': 'a2',
            'orderNumber': 102,
            'originType': 'Domicilio',
            'cancelledByName': 'Mesero Pruebas',
            'cancellationReason': 'Cliente desiste',
            'cancelledAt': '2026-04-22T14:30:00',
            'totalValue': 15000.00,
          },
        ],
      };

      final response = AnnulledOrdersReportResponse.fromJson(json);

      expect(response.startDateTime, DateTime(2026, 4, 22, 8, 0));
      expect(response.totalOrders, 2);
      expect(response.totalPaidAnnulled, 1);
      expect(response.totalPrePaidCancelled, 1);
      expect(response.totalValue, 45000.00);
      expect(response.totalTipAmount, 3000.00);
      expect(response.items, hasLength(2));

      final paid = response.items!.first;
      expect(paid.cancellationType, 'PAID_SALE');
      expect(paid.isPaidSale, isTrue);
      expect(paid.transactionNumber, 'TXN-20260422130000-000001');
      expect(paid.orderNumber, 101);
      expect(paid.cancelledByName, 'Admin Root');
      expect(paid.shiftNumber, 'CAJA-01-20260422-001');
      expect(paid.paymentMethods, hasLength(1));
      expect(paid.paymentMethods!.first.paymentMethod, 'CASH');
      expect(paid.paymentMethods!.first.amount, 33000.00);

      final pre = response.items!.last;
      expect(pre.cancellationType, 'PRE_PAID');
      expect(pre.isPaidSale, isFalse);
      expect(pre.transactionNumber, isNull);
      expect(pre.paymentMethods, isNull);
      expect(pre.cancelledByName, 'Mesero Pruebas');
    });

    test('tolera campos opcionales faltantes y totales nulos', () {
      final response = AnnulledOrdersReportResponse.fromJson({});

      expect(response.startDateTime, isNull);
      expect(response.totalOrders, isNull);
      expect(response.totalValue, isNull);
      expect(response.items, isNull);
    });

    test('acepta enteros como String en campos numericos', () {
      final json = {
        'totalOrders': '5',
        'totalPaidAnnulled': '3',
        'totalPrePaidCancelled': '2',
        'items': [],
      };
      final response = AnnulledOrdersReportResponse.fromJson(json);
      expect(response.totalOrders, 5);
      expect(response.totalPaidAnnulled, 3);
      expect(response.totalPrePaidCancelled, 2);
      expect(response.items, isEmpty);
    });

    test('paymentMethodInfo parsea correctamente', () {
      final info = PaymentMethodInfo.fromJson({'paymentMethod': 'CARD', 'amount': 5000.0});
      expect(info.paymentMethod, 'CARD');
      expect(info.amount, 5000.0);
    });
  });
}
