import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:restic_movil/app/data/models/table_model.dart';
import 'package:restic_movil/app/data/models/table_status_model.dart';
import 'package:restic_movil/app/data/repositories/tables_repository.dart';
import 'package:restic_movil/app/modules/tables/controllers/tables_controller.dart';
import 'package:restic_movil/app/modules/tables/views/tables_view.dart';
import 'package:restic_movil/app/modules/tables/views/widgets/table_form_modal.dart';
import 'package:restic_movil/app/modules/home/controllers/home_controller.dart';

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
  Future<List<TableModel>> getTables() async => mockTables;

  @override
  Future<List<TableStatusDTO>> getStatuses() async => mockStatuses;
  
  @override
  Future<List<TableModel>> getAvailableTables() async => [];
  @override
  Future<TableModel> getTableById(String id) async => mockTables.first;
  @override
  Future<List<TableModel>> getTablesByStatus(String status) async => [];
  @override
  Future<List<TableModel>> getTablesByLocation(String location) async => [];
  @override
  Future<List<TableModel>> createTables(List<Map<String, dynamic>> tables) async => [];
  @override
  Future<TableModel> updateTable(String id, Map<String, dynamic> table) async => mockTables.first;
  @override
  Future<void> deleteTable(String id) async {}
  @override
  Future<List<TableModel>> reserveTables(List<String> tableIds) async => [];
  @override
  Future<List<TableModel>> releaseTables(List<String> tableIds) async => [];
}

// Dummy para el CustomDrawer
class MockHomeController extends GetxController implements HomeController {
  @override
  final RxList<String> modules = ['MESAS', 'CAJA'].obs;
  final String userName = 'Admin Testing';
  final String role = 'SUPER';
  @override
  final RxInt currentIndex = 0.obs;
  @override
  final RxList<NavigationItem> navigationItems = <NavigationItem>[].obs;
  @override
  final RxString appVersion = 'Versión 1.0.0 (1)'.obs;

  @override
  final RxList<String> userRoles = <String>[].obs;

  @override
  final RxBool waiterViewOwnOrdersOnly = false.obs;

  @override
  Future<void> setWaiterViewOwnOrdersOnly(bool value) async {
    waiterViewOwnOrdersOnly.value = value;
  }

  @override
  Future<void> logout() async {}
  @override
  void changePage(int index) {}
  @override
  Future<String> getBranchName() async => 'Sucursal Test';
  @override
  Future<String> getUserName() async => 'Admin Testing';
}

void main() {
  group('TablesView Widget Tests', () {
    late TablesController controller;
    late MockTablesRepository mockRepository;

    setUp(() {
      Get.testMode = true;
      Get.reset(); // Restablece dependencias

      Get.put<HomeController>(MockHomeController());

      mockRepository = MockTablesRepository();
      controller = TablesController(repository: mockRepository);
      Get.put<TablesController>(controller);
    });

    testWidgets('Debe renderizar la pantalla y mostrar mesas iniciales', (tester) async {
      await tester.runAsync(() async {
        controller.onReady();
        await Future.delayed(const Duration(milliseconds: 100)); // Simulacion de data.
      });

      await tester.pumpWidget(
        const GetMaterialApp(
          home: TablesView(),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Gestión de Mesas'), findsOneWidget);
      expect(find.text('Mesa 1'), findsOneWidget);
      expect(find.text('Mesa 2'), findsOneWidget);
    });

    testWidgets('Al presionar Nueva Mesa se muestra el formulario (TableFormModal)', (tester) async {
      await tester.pumpWidget(
        const GetMaterialApp(
          home: TablesView(),
        ),
      );

      final button = find.widgetWithText(ElevatedButton, 'Nueva Mesa');
      expect(button, findsOneWidget);

      await tester.tap(button);
      await tester.pumpAndSettle();

      expect(find.byType(TableFormModal), findsOneWidget);
      expect(find.text('Nueva Mesa'), findsWidgets);
    });

    testWidgets('Selección de mesa activa el boton de Liberar y Reservar', (tester) async {
      await tester.runAsync(() async {
        controller.onReady(); 
        await Future.delayed(const Duration(milliseconds: 100));
      });

      await tester.pumpWidget(
        const GetMaterialApp(
          home: TablesView(),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.textContaining('Reservar'), findsNothing);
      expect(find.textContaining('Liberar'), findsNothing);

      await tester.longPress(find.text('Mesa 1'));
      await tester.pumpAndSettle();

      expect(controller.selectedTableIds.length, 1);
      expect(find.textContaining('Reservar'), findsOneWidget);
    });
  });
}
