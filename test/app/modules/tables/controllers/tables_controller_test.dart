import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:restic_movil/app/data/models/table_model.dart';
import 'package:restic_movil/app/data/models/table_status_model.dart';
import 'package:restic_movil/app/data/repositories/tables_repository.dart';
import 'package:restic_movil/app/modules/tables/controllers/tables_controller.dart';

class MockTablesRepository extends Fake implements TablesRepository {
  bool failMock = false;
  List<TableModel> mockTables = [
    TableModel(id: '1', name: 'Mesa 1', status: 'AVAILABLE', tableNumber: 1),
    TableModel(id: '2', name: 'Mesa 2', status: 'OCCUPIED', tableNumber: 2)
  ];
  
  List<TableStatusDTO> mockStatuses = [
    TableStatusDTO(name: 'AVAILABLE', description: 'Disponible'),
    TableStatusDTO(name: 'OCCUPIED', description: 'Ocupada'),
    TableStatusDTO(name: 'RESERVED', description: 'Reservada')
  ];

  @override
  Future<List<TableModel>> getTables() async {
    if (failMock) throw Exception('Error getting tables');
    return mockTables;
  }

  @override
  Future<List<TableStatusDTO>> getStatuses() async {
    if (failMock) throw Exception('Error getting statuses');
    return mockStatuses;
  }

  @override
  Future<List<TableModel>> getAvailableTables() async => [];
  @override
  Future<TableModel> getTableById(String id) async => TableModel();
  @override
  Future<List<TableModel>> getTablesByStatus(String status) async => [];
  @override
  Future<List<TableModel>> getTablesByLocation(String location) async => [];

  @override
  Future<List<TableModel>> createTables(List<Map<String, dynamic>> tables) async {
    final newTable = TableModel(
      id: '3', 
      name: tables.first['name'], 
      status: tables.first['status'],
      tableNumber: 3
    );
    mockTables.add(newTable);
    return [newTable];
  }

  @override
  Future<TableModel> updateTable(String id, Map<String, dynamic> table) async {
    final idx = mockTables.indexWhere((element) => element.id == id);
    if (idx != -1) {
      mockTables[idx] = TableModel(
        id: id,
        name: table['name'] ?? mockTables[idx].name,
        status: table['status'] ?? mockTables[idx].status,
        tableNumber: table['tableNumber'] ?? mockTables[idx].tableNumber,
      );
      return mockTables[idx];
    }
    return TableModel(id: id, name: table['name'], status: table['status']);
  }

  @override
  Future<void> deleteTable(String id) async {
    mockTables.removeWhere((element) => element.id == id);
  }

  @override
  Future<List<TableModel>> reserveTables(List<String> tableIds) async {
    for (var id in tableIds) {
      final idx = mockTables.indexWhere((element) => element.id == id);
      if (idx != -1) {
        mockTables[idx] = TableModel(
          id: id,
          name: mockTables[idx].name,
          status: 'RESERVED',
          tableNumber: mockTables[idx].tableNumber,
        );
      }
    }
    return mockTables;
  }
  
  @override
  Future<List<TableModel>> releaseTables(List<String> tableIds) async {
    for (var id in tableIds) {
      final idx = mockTables.indexWhere((element) => element.id == id);
      if (idx != -1) {
        mockTables[idx] = TableModel(
          id: id,
          name: mockTables[idx].name,
          status: 'AVAILABLE',
          tableNumber: mockTables[idx].tableNumber,
        );
      }
    }
    return mockTables;
  }
}

void main() {
  group('TablesController Test - QA', () {
    late TablesController controller;
    late MockTablesRepository mockRepository;

    setUp(() {
      Get.testMode = true;
      Get.reset();

      mockRepository = MockTablesRepository();
      controller = TablesController(repository: mockRepository);
      Get.put(controller);
    });

    testWidgets('Debe inicializar y cargar la data correctamente', (tester) async {
      await tester.pumpWidget(const GetMaterialApp(home: Scaffold(body: SizedBox())));
      
      await tester.runAsync(() async {
        controller.onReady();
        await Future.delayed(const Duration(milliseconds: 100)); // wait for future wait to finish
      });
      await tester.pumpAndSettle();

      expect(controller.tables.length, 2);
      expect(controller.statuses.length, 3);
      expect(controller.tables.first.name, 'Mesa 1');
    });

    test('prepareCreate debe asignar "AVAILABLE" como estado por defecto', () {
      controller.prepareCreate();
      expect(controller.isEditing.value, isFalse);
      expect(controller.editingTableId, isNull);
      expect(controller.tableForm.control('status').value, 'AVAILABLE');
    });

    test('prepareEdit debe rellenar el formulario correctamente', () {
      final table = TableModel(id: '1', name: 'Mesa Vip', status: 'RESERVED', tableNumber: 15);
      controller.prepareEdit(table);

      expect(controller.isEditing.value, isTrue);
      expect(controller.editingTableId, '1');
      expect(controller.tableForm.control('name').value, 'Mesa Vip');
      expect(controller.tableForm.control('status').value, 'RESERVED');
      expect(controller.tableForm.control('tableNumber').value, 15);
    });

    testWidgets('Alternar seleccion (toggleTableSelection) - canReserveSelected / canReleaseSelected', (tester) async {
      await tester.pumpWidget(const GetMaterialApp(home: Scaffold(body: SizedBox())));
      await tester.runAsync(() async {
        controller.onReady();
        await Future.delayed(const Duration(milliseconds: 100));
      });

      // Validar mesa AVAILABLE
      controller.toggleTableSelection('1'); // Mesa 1 is AVAILABLE
      expect(controller.selectedTableIds.length, 1);
      expect(controller.canReserveSelected, isTrue);
      expect(controller.canReleaseSelected, isFalse);

      // Desmarcar y marcar mesa ocupada
      controller.toggleTableSelection('1'); // Desmarco
      controller.toggleTableSelection('2'); // Mesa 2 is OCCUPIED
      expect(controller.canReserveSelected, isFalse);
      expect(controller.canReleaseSelected, isTrue);

      // Marcar mixtas
      controller.toggleTableSelection('1'); // Ambas marcadas
      expect(controller.canReserveSelected, isFalse);
      expect(controller.canReleaseSelected, isFalse);
    });
  });
}
