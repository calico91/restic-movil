import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:restic_movil/app/modules/home/controllers/home_controller.dart';
import 'package:restic_movil/app/modules/order_settings/controllers/order_settings_controller.dart';
import 'package:restic_movil/app/modules/order_settings/views/order_settings_view.dart';

class MockHomeController extends GetxController implements HomeController {
  @override
  final RxList<String> modules = <String>[].obs;
  @override
  final currentIndex = 0.obs;
  @override
  final RxList<NavigationItem> navigationItems = <NavigationItem>[].obs;
  @override
  final RxString appVersion = ''.obs;
  @override
  final RxList<String> userRoles = <String>[].obs;
  @override
  final RxBool waiterViewOwnOrdersOnly = false.obs;
  @override
  final RxString orderViewMode = 'list'.obs;

  @override
  void changePage(int index) => currentIndex.value = index;
  @override
  Future<String> getUserName() async => '';
  @override
  Future<String> getBranchName() async => '';
  @override
  Future<void> logout() async {}
  @override
  Future<void> setWaiterViewOwnOrdersOnly(bool value) async {
    waiterViewOwnOrdersOnly.value = value;
  }
  @override
  Future<void> setOrderViewMode(String mode) async {
    orderViewMode.value = mode;
  }
}

class MockOrderSettingsController extends OrderSettingsController {
  MockOrderSettingsController({required super.homeController});

  bool toggleCalled = false;
  bool? lastToggleValue;
  String? lastViewMode;

  @override
  Future<void> setWaiterViewOwnOrdersOnly(bool value) async {
    toggleCalled = true;
    lastToggleValue = value;
    await homeController.setWaiterViewOwnOrdersOnly(value);
  }

  @override
  Future<void> setOrderViewMode(String mode) async {
    lastViewMode = mode;
    await homeController.setOrderViewMode(mode);
  }
}

void main() {
  late MockHomeController mockHomeController;
  late MockOrderSettingsController mockOrderSettingsController;

  Widget createTestWidget() {
    return const GetMaterialApp(
      home: OrderSettingsView(),
    );
  }

  setUp(() {
    Get.reset();
    mockHomeController = MockHomeController();
    Get.put<HomeController>(mockHomeController);
    mockOrderSettingsController = MockOrderSettingsController(
      homeController: mockHomeController,
    );
    Get.put<OrderSettingsController>(mockOrderSettingsController);
  });

  tearDown(() {
    Get.reset();
  });

  testWidgets('Debe renderizar el título, la sección General con el selector de vista', (tester) async {
    await tester.pumpWidget(createTestWidget());
    await tester.pumpAndSettle();

    expect(find.text('Ajustes Generales'), findsOneWidget);
    expect(find.text('General'), findsOneWidget);
    expect(find.byType(SegmentedButton<String>), findsOneWidget);
    expect(find.text('Lista'), findsOneWidget);
    expect(find.text('Grilla'), findsOneWidget);
  });

  testWidgets('El modo de vista por defecto es lista y cambiar a grilla llama al setter', (tester) async {
    await tester.pumpWidget(createTestWidget());
    await tester.pumpAndSettle();

    expect(mockHomeController.orderViewMode.value, 'list');

    await tester.tap(find.text('Grilla'));
    await tester.pumpAndSettle();

    expect(mockOrderSettingsController.lastViewMode, 'grid');
    expect(mockHomeController.orderViewMode.value, 'grid');
  });

  testWidgets('Un usuario ADMIN debe ver la sección Pedidos y activar el switch', (tester) async {
    mockHomeController.userRoles.assignAll(['ADMINISTRADOR']);
    mockHomeController.waiterViewOwnOrdersOnly.value = false;

    await tester.pumpWidget(createTestWidget());
    await tester.pumpAndSettle();

    expect(find.text('Pedidos'), findsOneWidget);
    expect(find.text('Solo ver mis pedidos (meseros)'), findsOneWidget);

    await tester.tap(find.byType(SwitchListTile));
    await tester.pumpAndSettle();

    expect(mockOrderSettingsController.toggleCalled, isTrue);
    expect(mockOrderSettingsController.lastToggleValue, isTrue);
    expect(mockHomeController.waiterViewOwnOrdersOnly.value, isTrue);
  });

  testWidgets('Un usuario sin rol ADMIN/SUPER no debe ver la sección Pedidos', (tester) async {
    mockHomeController.userRoles.assignAll(['MESERO']);

    await tester.pumpWidget(createTestWidget());
    await tester.pumpAndSettle();

    expect(find.text('Solo ver mis pedidos (meseros)'), findsNothing);
    expect(find.text('Ajustes Generales'), findsOneWidget);
  });
}
