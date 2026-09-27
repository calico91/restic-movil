import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:reactive_forms/reactive_forms.dart';
import 'package:restic_movil/app/modules/menu/views/widgets/menu_forms.dart';

Widget testableHome(Widget child) => GetMaterialApp(
  home: ReactiveFormConfig(
    validationMessages: const {},
    child: Scaffold(body: child),
  ),
);

Future<void> pumpDialog(
  WidgetTester tester, {
  required ValueChanged<Map<String, dynamic>> onSubmit,
}) {
  return tester.pumpWidget(
    testableHome(
      ProductFormDialog(
        categoryId: 'c-1',
        subcategoryId: 's-1',
        onSubmit: onSubmit,
      ),
    ),
  );
}

Future<void> switchToVariable(WidgetTester tester) async {
  final dropdownField = find.byType(ReactiveDropdownField<String>);
  await tester.ensureVisible(dropdownField.last);
  await tester.tap(dropdownField.last);
  await tester.pumpAndSettle();
  await tester.tap(find.text('Variable (por tamaño)').last);
  await tester.pumpAndSettle();
}

Finder fieldByLabel(String label) {
  return find.ancestor(
    of: find.text(label),
    matching: find.byWidgetPredicate(
      (w) => w is TextField || w is TextFormField,
    ),
  );
}

Future<void> enterFieldText(
  WidgetTester tester,
  Finder fieldFinder,
  String text,
) async {
  await tester.ensureVisible(fieldFinder);
  await tester.enterText(fieldFinder, text);
  await tester.pump();
}

void main() {
  testWidgets('NO debe replicar el texto del campo Tamaño en el campo Precio', (
    tester,
  ) async {
    await pumpDialog(tester, onSubmit: (_) {});
    await switchToVariable(tester);

    final sizeField = fieldByLabel('Tamaño (ej: 12oz)').first;
    final priceField = fieldByLabel('Precio').first;
    expect(sizeField, findsOneWidget);
    expect(priceField, findsOneWidget);

    await enterFieldText(tester, sizeField, '12oz');

    final sizeText = tester.widget<TextField>(sizeField).controller!.text;
    final priceText = tester.widget<TextField>(priceField).controller!.text;
    expect(sizeText, '12oz');
    expect(
      priceText,
      isEmpty,
      reason: 'El texto del Tamaño no debe copiarse en el campo Precio',
    );
  });

  testWidgets(
    'debe escribir en la fila correcta al eliminar una fila intermedia',
    (tester) async {
      List<Map<String, dynamic>>? submitted;
      await pumpDialog(
        tester,
        onSubmit: (v) =>
            submitted = List<Map<String, dynamic>>.from(v['prices'] ?? []),
      );
      await switchToVariable(tester);

      final addButton = find
          .ancestor(
            of: find.text('Agregar Precio'),
            matching: find.byWidgetPredicate((w) => w is TextButton),
          )
          .first;
      await tester.ensureVisible(addButton);
      await tester.tap(addButton);
      await tester.pumpAndSettle();
      await tester.ensureVisible(addButton);
      await tester.tap(addButton);
      await tester.pumpAndSettle();

      final sizeFields = fieldByLabel('Tamaño (ej: 12oz)');
      final priceFields = fieldByLabel('Precio');

      await enterFieldText(tester, sizeFields.at(0), '12oz');
      await enterFieldText(tester, sizeFields.at(1), '16oz');
      await enterFieldText(tester, sizeFields.at(2), '20oz');
      await enterFieldText(tester, priceFields.at(0), '5000');
      await enterFieldText(tester, priceFields.at(1), '8000');
      await enterFieldText(tester, priceFields.at(2), '10000');

      final deleteButtons = find.byIcon(Icons.delete);
      expect(deleteButtons, findsNWidgets(3));
      await tester.ensureVisible(deleteButtons.at(1));
      await tester.tap(deleteButtons.at(1));
      await tester.pumpAndSettle();

      await enterFieldText(
        tester,
        fieldByLabel('Nombre del Producto').first,
        'T',
      );

      final remainingPriceField = fieldByLabel('Precio').at(1);
      expect(
        find.byWidget(tester.widget<TextField>(remainingPriceField)),
        findsOneWidget,
      );
      await enterFieldText(tester, remainingPriceField, '9000');

      await tester.ensureVisible(
        find.widgetWithText(ElevatedButton, 'Guardar'),
      );
      await tester.tap(find.widgetWithText(ElevatedButton, 'Guardar'));
      await tester.pumpAndSettle();

      expect(submitted, isNotNull);
      expect(submitted!.length, 2);
      expect(submitted![0]['size_label'], '12oz');
      expect(submitted![0]['amount'], 5000.0);
      expect(submitted![1]['size_label'], '20oz');
      expect(submitted![1]['amount'], 9000.0);
    },
  );
}
