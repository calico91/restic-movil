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
}

class MockOrderSettingsController extends OrderSettingsController {
  MockOrderSettingsController({required super.homeController});

  bool toggleCalled = false;
  bool? lastToggleValue;

  @override
  Future<void> setWaiterViewOwnOrdersOnly(bool value) async {
    toggleCalled = true;
    lastToggleValue = value;
    await homeController.setWaiterViewOwnOrdersOnly(value);
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

  testWidgets('Debe renderizar el título y el switch de filtro de meseros', (tester) async {
    await tester.pumpWidget(createTestWidget());
    await tester.pumpAndSettle();

    expect(find.text('Ajustes de Pedidos'), findsOneWidget);
    expect(find.text('Solo ver mis pedidos (meseros)'), findsOneWidget);
    expect(find.byType(SwitchListTile), findsOneWidget);
  });

  testWidgets('Un usuario ADMINISTRADOR debe poder activar el switch', (tester) async {
    mockHomeController.userRoles.assignAll(['ADMINISTRADOR']);
    mockHomeController.waiterViewOwnOrdersOnly.value = false;

    await tester.pumpWidget(createTestWidget());
    await tester.pumpAndSettle();

    await tester.tap(find.byType(SwitchListTile));
    await tester.pumpAndSettle();

    expect(mockOrderSettingsController.toggleCalled, isTrue);
    expect(mockOrderSettingsController.lastToggleValue, isTrue);
    expect(mockHomeController.waiterViewOwnOrdersOnly.value, isTrue);
  });

  testWidgets('Un usuario sin rol ADMIN/SUPER debe ver el switch deshabilitado y el aviso', (tester) async {
    mockHomeController.userRoles.assignAll(['MESERO']);
    mockHomeController.waiterViewOwnOrdersOnly.value = false;

    await tester.pumpWidget(createTestWidget());
    await tester.pumpAndSettle();

    expect(
      find.textContaining('Solo usuarios con rol ADMINISTRADOR'),
      findsOneWidget,
    );

    final SwitchListTile switchTile = tester.widget(find.byType(SwitchListTile));
    expect(switchTile.onChanged, isNull);
  });
}
