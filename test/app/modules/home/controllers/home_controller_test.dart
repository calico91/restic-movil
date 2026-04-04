import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:restic_movil/app/data/models/login_response.dart';
import 'package:restic_movil/app/data/services/storage_service.dart';
import 'package:restic_movil/app/modules/home/controllers/home_controller.dart';

// Generamos un Mock manual (Fake) del StorageService para aislar la base de datos segura y controlar lo que devuelve
class MockStorageService extends GetxService implements StorageService {
  LoginResponse? mockUser;
  String? mockBranchId = '10000000-0000-0000-0000-000000000001';

  @override
  Future<LoginResponse?> getUser() async {
    return mockUser;
  }

  @override
  Future<String?> getBranchId() async {
    return mockBranchId;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) {
    return super.noSuchMethod(invocation);
  }
  @override
  Future<void> saveServerUrl(String url) async {}
  @override
  Future<String?> getServerUrl() async => "http://192.168.0.103:8093";
  @override
  Future<void> deleteServerUrl() async {}
}

void main() {
  group('Pruebas Unitarias - HomeController (Accesos por Módulo)', () {
    late HomeController controller;
    late MockStorageService mockStorageService;

    setUp(() {
      // Configuramos el entorno antes de cada test aislando las dependencias
      mockStorageService = MockStorageService();
      Get.put<StorageService>(mockStorageService);
    });

    tearDown(() {
      // Limpiamos el inyector de dependencias (DI) de GetX despues de cada prueba
      Get.reset();
    });

    test('Debe cargar todos los ítems de navegación si tiene los tres módulos completos (SUPER)', () async {
      // Arrange (Preparación)
      mockStorageService.mockUser = LoginResponse(
        id: 'user-001',
        name: 'Administrador',
        modules: ['PEDIDOS', 'COMANDAS', 'CAJA'], // Permisos completos
      );
      
      // Act (Ejecución)
      controller = Get.put(HomeController());
      await Future.delayed(Duration.zero); // Esperamos la resolución del asíncronismo en onInit()

      // Assert (Verificación)
      expect(controller.modules.length, 3);
      expect(controller.navigationItems.length, 3);
      expect(controller.navigationItems.any((item) => item.title == 'Pedidos'), isTrue);
      expect(controller.navigationItems.any((item) => item.title == 'Comandas'), isTrue);
      expect(controller.navigationItems.any((item) => item.title == 'Caja'), isTrue);
    });

    test('Debe cargar solo items permitidos para un CAJERO (Módulos CAJA y PEDIDOS)', () async {
      // Arrange
      mockStorageService.mockUser = LoginResponse(
        id: 'user-002',
        name: 'Cajero',
        modules: ['CAJA', 'PEDIDOS'], // Faltaría COMANDAS
      );

      // Act
      controller = Get.put(HomeController());
      await Future.delayed(Duration.zero); 

      // Assert
      expect(controller.modules.length, 2);
      expect(controller.navigationItems.length, 2);
      expect(controller.navigationItems.any((item) => item.title == 'Pedidos'), isTrue);
      expect(controller.navigationItems.any((item) => item.title == 'Caja'), isTrue);
      // Validamos que su contraparte NO esté en la lista por falta de permiso
      expect(controller.navigationItems.any((item) => item.title == 'Comandas'), isFalse);
    });

    test('Debe inicializar la UI en 0 items si el usuario reporta permisos distintos o vacíos', () async {
      // Arrange
      mockStorageService.mockUser = LoginResponse(
        id: 'user-003',
        name: 'Repartidor',
        modules: ['OTRO_MODULO', 'CONFIGURACION'], // Ninguno mapeado a las vistas bases del bottom navigation
      );

      // Act
      controller = Get.put(HomeController());
      await Future.delayed(Duration.zero);

      // Assert
      expect(controller.navigationItems.length, 0); // No debería mostrar cajones inferioes
    });

    test('Debe capturar sin errores si no se encuentra un usuario cacheado (Token expirado/eliminado)', () async {
      // Arrange
      mockStorageService.mockUser = null;

      // Act
      controller = Get.put(HomeController());
      await Future.delayed(Duration.zero);

      // Assert
      // Los arrays de módulos y navegación se inician vacíos y no deben chocar al evaluar las promesas
      expect(controller.modules.length, 0);
      expect(controller.navigationItems.length, 0);
    });
  });
}
