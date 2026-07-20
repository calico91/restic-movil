import 'package:flutter_test/flutter_test.dart';
import 'package:restic_movil/app/data/models/category_model.dart';
import 'package:restic_movil/app/data/models/order_item_model.dart';
import 'package:restic_movil/app/data/models/printer_zone_model.dart';
import 'package:restic_movil/core/utils/printers/category_printer_resolver.dart';

void main() {
  // Cat -> Sub -> Prod( con subcategoryId )
  CategoryModel buildCategory({
    required String id,
    required String subId,
    String? printerIp, // legacy, debe ser ignorado
  }) {
    return CategoryModel(
      id: id,
      name: id,
      printerIp: printerIp,
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

  group('CategoryPrinterResolver - Casos 1, 2 y 3', () {
    test('Caso 1: sin zonas custom, todas las comandas van a Caja (null)', () {
      final categories = [
        buildCategory(id: 'cat1', subId: 'sub1'),
        buildCategory(id: 'cat2', subId: 'sub2'),
      ];
      final items = [buildItem('sub1'), buildItem('sub2')];

      final groups = CategoryPrinterResolver.groupItemsByPrinter(
        items,
        categories,
        zones: const [],
        mappings: const {},
      );

      expect(groups.length, 1);
      expect(groups.containsKey(null), isTrue);
      expect(groups[null]!.length, 2);
    });

    test('Caso 1: aunque la categoria tenga printerIp legacy, se ignora', () {
      final categories = [
        buildCategory(id: 'cat1', subId: 'sub1', printerIp: '192.168.99.99'),
      ];
      final items = [buildItem('sub1')];

      final groups = CategoryPrinterResolver.groupItemsByPrinter(
        items,
        categories,
        zones: const [],
        mappings: const {},
      );

      expect(groups.length, 1);
      expect(groups.containsKey(null), isTrue,
          reason: 'No debe usar el printerIp legacy');
    });

    test('Caso 2: una zona custom con 1 cat asignada, resto a Caja', () {
      final categories = [
        buildCategory(id: 'cat_jugos', subId: 'sub_jugos'),
        buildCategory(id: 'cat_caliente', subId: 'sub_caliente'),
      ];
      final items = [buildItem('sub_jugos'), buildItem('sub_caliente')];

      final zonas = [
        const PrinterZoneModel(
          id: 'zone_jugos',
          name: 'Jugos',
          ip: '192.168.1.50',
          port: 9100,
        ),
      ];
      final mappings = {'cat_jugos': 'zone_jugos'};

      final groups = CategoryPrinterResolver.groupItemsByPrinter(
        items,
        categories,
        zones: zonas,
        mappings: mappings,
      );

      expect(groups.length, 2);
      // Jugos => NetworkPrinterModel con IP de la zona
      final jugosKey = groups.keys.firstWhere(
        (k) => k != null && k.ip == '192.168.1.50',
        orElse: () => null,
      );
      expect(jugosKey, isNotNull);
      expect(groups[jugosKey]!.length, 1);
      // Caliente => null (Caja)
      expect(groups.containsKey(null), isTrue);
      expect(groups[null]!.length, 1);
    });

    test('Caso 3: 3 impresoras (Caja + Jugos + Caliente), categorias no asignadas caen a Caja', () {
      final categories = [
        buildCategory(id: 'cat_jugos', subId: 'sub_jugos'),
        buildCategory(id: 'cat_caliente1', subId: 'sub_caliente1'),
        buildCategory(id: 'cat_caliente2', subId: 'sub_caliente2'),
      ];
      final items = [
        buildItem('sub_jugos'),
        buildItem('sub_caliente1'),
        buildItem('sub_caliente2'),
      ];

      final zonas = [
        const PrinterZoneModel(
          id: 'zone_jugos',
          name: 'Jugos',
          ip: '192.168.1.50',
          port: 9100,
        ),
        const PrinterZoneModel(
          id: 'zone_caliente',
          name: 'Caliente',
          ip: '192.168.1.60',
          port: 9100,
        ),
      ];
      // 1 cat a Jugos; las otras 2 sin asignar => caen a Caja (null)
      final mappings = {'cat_jugos': 'zone_jugos'};

      final groups = CategoryPrinterResolver.groupItemsByPrinter(
        items,
        categories,
        zones: zonas,
        mappings: mappings,
      );

      // 2 grupos: Jugos y Caja (null). Caliente NO recibe items porque
      // ninguna categoria esta asignada alla.
      expect(groups.length, 2);
      expect(groups.containsKey(null), isTrue,
          reason: 'Categorias sin asignar caen a Caja');

      final jugosKey = groups.keys.firstWhere(
        (k) => k != null && k.ip == '192.168.1.50',
        orElse: () => null,
      );
      expect(jugosKey, isNotNull);
      expect(groups[jugosKey]!.length, 1);

      expect(groups[null]!.length, 2,
          reason: 'cat_caliente1 + cat_caliente2 caen a Caja');
    });

    test('Caso 3 con TODAS las categorias asignadas: Caja NO recibe comandas', () {
      final categories = [
        buildCategory(id: 'cat_jugos', subId: 'sub_jugos'),
        buildCategory(id: 'cat_caliente1', subId: 'sub_caliente1'),
      ];
      final items = [
        buildItem('sub_jugos'),
        buildItem('sub_caliente1'),
      ];

      final zonas = [
        const PrinterZoneModel(
          id: 'zone_jugos',
          name: 'Jugos',
          ip: '192.168.1.50',
          port: 9100,
        ),
        const PrinterZoneModel(
          id: 'zone_caliente',
          name: 'Caliente',
          ip: '192.168.1.60',
          port: 9100,
        ),
      ];
      // TODAS las categorias asignadas a una zona custom
      final mappings = {
        'cat_jugos': 'zone_jugos',
        'cat_caliente1': 'zone_caliente',
      };

      final groups = CategoryPrinterResolver.groupItemsByPrinter(
        items,
        categories,
        zones: zonas,
        mappings: mappings,
      );

      // 2 grupos (Jugos y Caliente). Caja NO recibe items.
      expect(groups.length, 2);
      expect(groups.containsKey(null), isFalse,
          reason: 'Caja no debe recibir comandas si todas las categorias '
              'estan asignadas a zonas custom');
    });

    test('Mapeo explicito a Caja => null (Caja)', () {
      final categories = [buildCategory(id: 'cat1', subId: 'sub1')];
      final items = [buildItem('sub1')];

      final groups = CategoryPrinterResolver.groupItemsByPrinter(
        items,
        categories,
        zones: const [],
        mappings: {'cat1': kCajaZoneId},
      );

      expect(groups.length, 1);
      expect(groups.containsKey(null), isTrue,
          reason: 'Mapeo explicito a Caja => null');
    });

    test(
        'Regresion: dos zonas con la MISMA IP:puerto generan 2 grupos separados',
        () {
      // Caso del usuario durante pruebas: ambas zonas apuntan a la misma
      // IP:puerto (una sola impresora fisica). El resolver debe generar
      // DOS grupos (uno por zona) para que se emita un ticket por zona.
      final categories = [
        buildCategory(id: 'cat_bebidas', subId: 'sub_bebidas'),
        buildCategory(id: 'cat_desayunos', subId: 'sub_desayunos'),
      ];
      final items = [
        buildItem('sub_bebidas'),
        buildItem('sub_desayunos'),
      ];

      const String sharedIp = '192.168.1.50';
      const int sharedPort = 9100;

      final zonas = [
        const PrinterZoneModel(
          id: 'zone_bebidas',
          name: 'Bebidas',
          ip: sharedIp,
          port: sharedPort,
        ),
        const PrinterZoneModel(
          id: 'zone_primer_piso',
          name: 'Primer Piso',
          ip: sharedIp,
          port: sharedPort,
        ),
      ];
      final mappings = {
        'cat_bebidas': 'zone_bebidas',
        'cat_desayunos': 'zone_primer_piso',
      };

      final groups = CategoryPrinterResolver.groupItemsByPrinter(
        items,
        categories,
        zones: zonas,
        mappings: mappings,
      );

      // Deben ser 2 grupos (no 1), uno por zona, gracias al == que incluye name.
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
