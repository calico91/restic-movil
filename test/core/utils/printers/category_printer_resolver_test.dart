import 'package:flutter_test/flutter_test.dart';
import 'package:restic_movil/app/data/models/category_model.dart';
import 'package:restic_movil/app/data/models/order_item_model.dart';
import 'package:restic_movil/app/data/models/printer_zone_model.dart';
import 'package:restic_movil/core/utils/printers/category_printer_resolver.dart';

void main() {
  CategoryModel buildCategory({
    required String id,
    required String subId,
    PrinterZoneModel? printerZone,
  }) {
    return CategoryModel(
      id: id,
      name: id,
      printerZone: printerZone,
      subcategories: [
        SubcategoryModel(
          id: subId,
          name: 'sub_$subId',
          products: [ProductModel(id: 'p_$subId', name: 'p_$subId', subcategoryId: subId)],
        ),
      ],
    );
  }

  OrderItemModel buildItem(String subId) {
    return OrderItemModel(
      product: ProductModel(id: 'p_$subId', name: 'p_$subId', subcategoryId: subId),
    );
  }

  group('CategoryPrinterResolver - con printerZone en Category', () {
    test('Sin zona asignada, todas las comandas van a Caja (null)', () {
      final categories = [
        buildCategory(id: 'cat1', subId: 'sub1'),
        buildCategory(id: 'cat2', subId: 'sub2'),
      ];
      final items = [buildItem('sub1'), buildItem('sub2')];

      final groups = CategoryPrinterResolver.groupItemsByPrinter(items, categories);

      expect(groups.length, 1);
      expect(groups.containsKey(null), isTrue);
      expect(groups[null]!.length, 2);
    });

    test('Una zona custom con 1 cat asignada, resto a Caja', () {
      final categories = [
        buildCategory(
          id: 'cat_jugos',
          subId: 'sub_jugos',
          printerZone: const PrinterZoneModel(
            id: 'zone_jugos',
            name: 'Jugos',
            ip: '192.168.1.50',
            port: 9100,
          ),
        ),
        buildCategory(id: 'cat_caliente', subId: 'sub_caliente'),
      ];
      final items = [buildItem('sub_jugos'), buildItem('sub_caliente')];

      final groups = CategoryPrinterResolver.groupItemsByPrinter(items, categories);

      expect(groups.length, 2);
      final jugosKey = groups.keys.firstWhere(
        (k) => k != null && k.ip == '192.168.1.50',
        orElse: () => null,
      );
      expect(jugosKey, isNotNull);
      expect(groups[jugosKey]!.length, 1);
      expect(groups.containsKey(null), isTrue);
      expect(groups[null]!.length, 1);
    });

    test('3 impresoras (Caja + Jugos + Caliente), categorias sin zona caen a Caja', () {
      final categories = [
        buildCategory(
          id: 'cat_jugos',
          subId: 'sub_jugos',
          printerZone: const PrinterZoneModel(
            id: 'zone_jugos',
            name: 'Jugos',
            ip: '192.168.1.50',
            port: 9100,
          ),
        ),
        buildCategory(id: 'cat_caliente1', subId: 'sub_caliente1'),
        buildCategory(id: 'cat_caliente2', subId: 'sub_caliente2'),
      ];
      final items = [
        buildItem('sub_jugos'),
        buildItem('sub_caliente1'),
        buildItem('sub_caliente2'),
      ];

      final groups = CategoryPrinterResolver.groupItemsByPrinter(items, categories);

      expect(groups.length, 2);
      expect(groups.containsKey(null), isTrue);

      final jugosKey = groups.keys.firstWhere(
        (k) => k != null && k.ip == '192.168.1.50',
        orElse: () => null,
      );
      expect(jugosKey, isNotNull);
      expect(groups[jugosKey]!.length, 1);
      expect(groups[null]!.length, 2,
          reason: 'cat_caliente1 + cat_caliente2 caen a Caja');
    });

    test('TODAS las categorias asignadas a zonas custom: Caja NO recibe comandas', () {
      final categories = [
        buildCategory(
          id: 'cat_jugos',
          subId: 'sub_jugos',
          printerZone: const PrinterZoneModel(
            id: 'zone_jugos',
            name: 'Jugos',
            ip: '192.168.1.50',
            port: 9100,
          ),
        ),
        buildCategory(
          id: 'cat_caliente1',
          subId: 'sub_caliente1',
          printerZone: const PrinterZoneModel(
            id: 'zone_caliente',
            name: 'Caliente',
            ip: '192.168.1.60',
            port: 9100,
          ),
        ),
      ];
      final items = [
        buildItem('sub_jugos'),
        buildItem('sub_caliente1'),
      ];

      final groups = CategoryPrinterResolver.groupItemsByPrinter(items, categories);

      expect(groups.length, 2);
      expect(groups.containsKey(null), isFalse,
          reason: 'Caja no recibe comandas si todas las categorias '
              'estan asignadas a zonas custom');
    });

    test(
        'Regresion: dos zonas con la MISMA IP:puerto generan 2 grupos separados',
        () {
      final categories = [
        buildCategory(
          id: 'cat_bebidas',
          subId: 'sub_bebidas',
          printerZone: const PrinterZoneModel(
            id: 'zone_bebidas',
            name: 'Bebidas',
            ip: '192.168.1.50',
            port: 9100,
          ),
        ),
        buildCategory(
          id: 'cat_desayunos',
          subId: 'sub_desayunos',
          printerZone: const PrinterZoneModel(
            id: 'zone_primer_piso',
            name: 'Primer Piso',
            ip: '192.168.1.50',
            port: 9100,
          ),
        ),
      ];
      final items = [
        buildItem('sub_bebidas'),
        buildItem('sub_desayunos'),
      ];

      final groups = CategoryPrinterResolver.groupItemsByPrinter(items, categories);

      expect(groups.length, 2,
          reason: 'Zonas con misma IP:puerto deben separarse por nombre');
      expect(groups.containsKey(null), isFalse);

      final bebidasKey = groups.keys.firstWhere(
        (k) => k != null && k.name == 'Bebidas',
        orElse: () => null,
      );
      expect(bebidasKey, isNotNull);
      expect(groups[bebidasKey]!.length, 1);

      final primerPisoKey = groups.keys.firstWhere(
        (k) => k != null && k.name == 'Primer Piso',
        orElse: () => null,
      );
      expect(primerPisoKey, isNotNull);
      expect(groups[primerPisoKey]!.length, 1);
    });
  });
}
