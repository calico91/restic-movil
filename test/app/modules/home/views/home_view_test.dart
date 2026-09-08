import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:restic_movil/app/modules/home/controllers/home_controller.dart';
import 'package:restic_movil/app/modules/home/views/home_view.dart';

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
  void changePage(int index) {
    currentIndex.value = index;
  }

  @override
  Future<String> getUserName() async => 'Usuario QA';

  @override
  Future<String> getBranchName() async => 'Sucursal Central';

  @override
  Future<void> logout() async {}

  @override
  Future<void> setWaiterViewOwnOrdersOnly(bool value) async {
    waiterViewOwnOrdersOnly.value = value;
  }
}

Widget _wrap(Widget child, {required double bottomViewPadding}) {
  return GetMaterialApp(
    home: MediaQuery(
      data: MediaQueryData(
        size: const Size(360, 800),
        viewPadding: EdgeInsets.only(bottom: bottomViewPadding),
        padding: EdgeInsets.only(bottom: bottomViewPadding),
      ),
      child: child,
    ),
  );
}

void main() {
  late MockHomeController mockHomeController;

  setUp(() {
    Get.reset();
    mockHomeController = MockHomeController();
    mockHomeController.navigationItems.assignAll([
      NavigationItem(
        title: 'Inicio',
        icon: Icons.home,
        view: const SizedBox.expand(),
        allowedModules: const ['INICIO'],
      ),
    ]);
    Get.put<HomeController>(mockHomeController);
  });

  tearDown(() {
    Get.reset();
  });

  testWidgets(
    'Con navegación por gestos (viewPadding.bottom = 0) la barra mantiene 30 px de margen inferior',
    (tester) async {
      await tester.pumpWidget(_wrap(const HomeView(), bottomViewPadding: 0));
      await tester.pumpAndSettle();

      final paddings = tester.widgetList<Padding>(find.byType(Padding));
      final bottomNavPadding = paddings.firstWhere(
        (p) => (p.padding as EdgeInsets).bottom == 30.0,
        orElse: () => throw TestFailure(
          'No se encontró el Padding inferior del bottomNavigationBar con bottom=30',
        ),
      );
      expect(
        (bottomNavPadding.padding as EdgeInsets).bottom,
        30.0,
        reason:
            'Sin inset del sistema el margen inferior debe ser exactamente 30 px',
      );
    },
  );

  testWidgets(
    'Con botones de 3 botones (viewPadding.bottom = 48) la barra añade el inset del sistema',
    (tester) async {
      await tester.pumpWidget(_wrap(const HomeView(), bottomViewPadding: 48));
      await tester.pumpAndSettle();

      final paddings = tester.widgetList<Padding>(find.byType(Padding));
      final bottomNavPadding = paddings.firstWhere(
        (p) => (p.padding as EdgeInsets).bottom == 78.0,
        orElse: () => throw TestFailure(
          'No se encontró el Padding inferior del bottomNavigationBar con bottom=78',
        ),
      );
      expect(
        (bottomNavPadding.padding as EdgeInsets).bottom,
        78.0,
        reason:
            'Con inset de 48 px la barra debe sumar 30 + 48 = 78 px para no chocar con los botones',
      );
    },
  );
}
