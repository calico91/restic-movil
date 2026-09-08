import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:restic_movil/app/modules/home/controllers/home_controller.dart';
import 'package:restic_movil/app/modules/home/views/widgets/custom_drawer.dart';

// Mock del Controlador
class MockHomeController extends GetxController implements HomeController {
  @override
  final RxList<String> modules = <String>[].obs;

  @override
  final currentIndex = 0.obs;

  @override
  final RxList<NavigationItem> navigationItems = <NavigationItem>[].obs;

  @override
  final RxString appVersion = 'Versión 1.0.0 (1)'.obs;

  @override
  void changePage(int index) {
    currentIndex.value = index;
  }

  @override
  Future<String> getUserName() async => 'Usuario QA';

  @override
  Future<String> getBranchName() async => 'Sucursal Central';

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

}

void main() {
  group('Pruebas de UI - Accesos del Drawer según Roles/Módulos', () {
    late MockHomeController mockHomeController;

    setUp(() {
      Get.reset();
      mockHomeController = MockHomeController();
      Get.put<HomeController>(mockHomeController);
    });

    testWidgets('Debe mostrar únicamente "Menú" y "Clientes" si los módulos permitidos son solo esos', (tester) async {
      mockHomeController.modules.assignAll(['MENU', 'CLIENTES']);

      await tester.pumpWidget(
        const GetMaterialApp(
          home: Scaffold(
            body: CustomDrawer(),
          ),
        ),
      );

      // Esperar a que se resuelvan los FutureBuilder del nombre de usuario y sucursal
      await tester.pumpAndSettle();

      // Assert: Verificar los que SI deben estar
      expect(find.text('Menú'), findsOneWidget);
      expect(find.text('Clientes'), findsOneWidget);
      expect(find.text('Cerrar Sesión'), findsOneWidget); // Siempre está

      // Assert: Verificar que el resto estén ocultos
      expect(find.text('Usuarios'), findsNothing);
      expect(find.text('Opciones de Caja'), findsNothing);
      expect(find.text('Reportes'), findsNothing);
      expect(find.text('Configuración'), findsNothing);
    });

    testWidgets('Debe mostrar "Opciones de Caja" si tiene permiso de "OPCIONES_CAJA"', (tester) async {
      mockHomeController.modules.assignAll(['OPCIONES_CAJA']);

      await tester.pumpWidget(
        const GetMaterialApp(
          home: Scaffold(
            body: CustomDrawer(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Assert
      expect(find.text('Opciones de Caja'), findsOneWidget);
      
      // Al ser un ExpansionTile, vamos a verificar que estén sus submódulos
      await tester.tap(find.text('Opciones de Caja'));
      await tester.pumpAndSettle();
      
      expect(find.text('Apertura de Caja'), findsOneWidget);
      expect(find.text('Cierre de Caja'), findsOneWidget);
      expect(find.text('Egresos de Caja'), findsOneWidget);

      expect(find.text('Usuarios'), findsNothing);
      expect(find.text('Reportes'), findsNothing);
    });

    testWidgets('Un rol SUPER o ADMIN (todos los módulos) debe mostrar absolutamente todo el menú', (tester) async {
      mockHomeController.modules.assignAll([
        'USUARIOS',
        'MENU',
        'CLIENTES',
        'OPCIONES_CAJA',
        'REPORTES',
        'CONFIGURACION_IMPRESORA',
        'CONFIGURACION_DATOS_FISCALES'
      ]);
      mockHomeController.userRoles.assignAll(['ADMINISTRADOR']);

      await tester.pumpWidget(
        const GetMaterialApp(
          home: Scaffold(
            body: CustomDrawer(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Usuarios'), findsOneWidget);
      expect(find.text('Menú'), findsOneWidget);
      expect(find.text('Clientes'), findsOneWidget);
      expect(find.text('Opciones de Caja'), findsOneWidget);

      // Hacemos scroll hacia abajo en el ListView para asegurarnos de que los últimos elementos se rendericen en las dimensiones de prueba
      await tester.drag(find.byType(ListView).first, const Offset(0, -500));
      await tester.pumpAndSettle();

      expect(find.text('Reportes'), findsOneWidget);
      expect(find.text('Configuración'), findsOneWidget);

      // Expandir Configuración para verificar el sub-ítem "Ajustes de Pedidos"
      await tester.tap(find.text('Configuración'));
      await tester.pumpAndSettle();

      expect(find.text('Ajustes de Pedidos'), findsOneWidget);
    });

    testWidgets('Un usuario sin rol ADMIN/SUPER no debe ver "Ajustes de Pedidos" en Configuración', (tester) async {
      mockHomeController.modules.assignAll([
        'CONFIGURACION_IMPRESORA',
        'CONFIGURACION_DATOS_FISCALES',
      ]);
      mockHomeController.userRoles.assignAll(['MESERO']);

      await tester.pumpWidget(
        const GetMaterialApp(
          home: Scaffold(
            body: CustomDrawer(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.drag(find.byType(ListView).first, const Offset(0, -500));
      await tester.pumpAndSettle();

      expect(find.text('Configuración'), findsOneWidget);
      await tester.tap(find.text('Configuración'));
      await tester.pumpAndSettle();

      expect(find.text('Ajustes de Pedidos'), findsNothing);
    });
  });
}
