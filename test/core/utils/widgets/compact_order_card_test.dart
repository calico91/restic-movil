import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:restic_movil/app/data/models/customer_model.dart';
import 'package:restic_movil/app/data/models/origin_type.dart';
import 'package:restic_movil/app/data/models/order_model.dart';
import 'package:restic_movil/app/data/models/table_model.dart';
import 'package:restic_movil/core/utils/widgets/compact_order_card.dart';

void main() {
  OrderModel baseOrder({
    String? originCode,
    String? originDesc,
    List<TableModel>? tables,
    CustomerModel? customer,
    String? openingDate,
  }) {
    return OrderModel(
      orderNumber: 42,
      status: 'Abierta',
      total: 150.0,
      openingDate: openingDate,
      originType: OriginType(code: originCode, description: originDesc),
      tables: tables,
      customer: customer,
    );
  }

  Future<void> pumpCard(
    WidgetTester tester,
    OrderModel order, {
    bool showTotal = false,
    bool showDate = false,
  }) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: SizedBox(
              width: 130,
              child: CompactOrderCard(
                order: order,
                showTotal: showTotal,
                showDate: showDate,
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('Salón: siempre muestra el número y las mesas asignadas', (tester) async {
    await pumpCard(
      tester,
      baseOrder(
        originDesc: 'Salón',
        tables: [TableModel(name: 'Mesa 5'), TableModel(name: 'Mesa 6')],
      ),
      showTotal: true,
    );

    expect(find.text('#42'), findsOneWidget);
    expect(find.text('Mesa 5, Mesa 6'), findsOneWidget);
    expect(find.text('Total'), findsOneWidget);
  });

  testWidgets('Para llevar: muestra cliente y hora', (tester) async {
    await pumpCard(
      tester,
      baseOrder(
        originCode: 'TAKE_AWAY',
        originDesc: 'Para llevar',
        customer: CustomerModel(name: 'Juan', lastName: 'Pérez'),
        openingDate: '2026-01-05T10:30:00',
      ),
    );

    expect(find.text('#42'), findsOneWidget);
    expect(find.text('Juan Pérez'), findsOneWidget);
    expect(find.text('10:30'), findsOneWidget);
  });

  testWidgets('Domicilio: muestra cliente y dirección', (tester) async {
    await pumpCard(
      tester,
      baseOrder(
        originCode: 'DELIVERY',
        originDesc: 'Domicilio',
        customer: CustomerModel(name: 'Ana', address: 'Calle Falsa 123'),
      ),
    );

    expect(find.text('#42'), findsOneWidget);
    expect(find.text('Ana'), findsOneWidget);
    expect(find.text('Calle Falsa 123'), findsOneWidget);
  });

  testWidgets('Domicilio sin dirección: muestra el teléfono como fallback', (tester) async {
    await pumpCard(
      tester,
      baseOrder(
        originCode: 'DELIVERY',
        originDesc: 'Domicilio',
        customer: CustomerModel(name: 'Ana', phone: '555-1234'),
      ),
    );

    expect(find.text('#42'), findsOneWidget);
    expect(find.text('Ana'), findsOneWidget);
    expect(find.text('555-1234'), findsOneWidget);
  });

  testWidgets('Domicilio en grilla de celular: sin overflow en la celda', (tester) async {
    tester.view.physicalSize = const Size(720, 1600);
    tester.view.devicePixelRatio = 2.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: GridView.builder(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.only(left: 16, right: 16, top: 16),
            gridDelegate: orderGridDelegateFor(360 - 32),
            itemCount: 6,
            itemBuilder: (context, index) => CompactOrderCard(
              order: baseOrder(
                originCode: 'DELIVERY',
                originDesc: 'Domicilio',
                customer: CustomerModel(name: 'Ana', address: 'Calle Falsa 123'),
              ),
              statusLabel: 'Abierta',
              showTotal: true,
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    expect(find.byType(CompactOrderCard), findsNWidgets(6));
  });
}
