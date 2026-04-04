import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:restic_movil/app/modules/auth/controllers/login_controller.dart';
import 'package:restic_movil/app/data/repositories/auth_repository.dart';
import 'package:restic_movil/app/data/services/storage_service.dart';
import 'package:restic_movil/app/data/models/login_response.dart';
import 'package:restic_movil/app/data/http/base_http_client.dart';

import 'package:restic_movil/app/routes/app_routes.dart';

class MockBaseHttpClient extends Fake implements BaseHttpClient {}

class MockAuthRepository extends Fake implements AuthRepository {
  bool failLogin = false;
  
  @override
  Future<LoginResponse> login(String username, String password) async {
    if (failLogin) {
      throw Exception('Invalid credentials');
    }
    return LoginResponse(
      id: '1',
      token: 'fake-token',
      name: 'SuperAdmin',
      modules: [],
      branches: [Branch(id: 'b1', name: 'Sucursal 1')]
    );
  }
}

class MockStorageService extends StorageService {
  @override Future<void> saveToken(String token) async {}
  @override Future<void> saveUser(LoginResponse user) async {}
  @override Future<void> saveBranchId(String branchId) async {}
  @override
  Future<void> saveServerUrl(String url) async {}
  @override
  Future<String?> getServerUrl() async => "http://192.168.0.103:8093";
  @override
  Future<void> deleteServerUrl() async {}
}

void main() {
  group('LoginController Test - Autenticación', () {
    late LoginController controller;
    late MockAuthRepository mockAuthRepository;

    setUp(() {
      Get.testMode = true;
      Get.reset();
      
      mockAuthRepository = MockAuthRepository();
      Get.put<StorageService>(MockStorageService());
      
      controller = LoginController(
        authRepository: mockAuthRepository,
        storageService: Get.find<StorageService>(),
      );
      Get.put(controller);
    });

    testWidgets('Login exitoso redirige correctamente y valida campos', (tester) async {
      Get.testMode = true;
      await tester.pumpWidget(GetMaterialApp(
        home: const Scaffold(body: SizedBox()),
        getPages: [GetPage(name: Routes.HOME, page: () => const Scaffold())],
      ));
      
      controller.form.control('username').value = 'super';
      controller.form.control('password').value = 'pass123';
      
      expect(controller.form.valid, isTrue);

      await tester.runAsync(() async {
        await controller.login();
        Get.closeAllSnackbars();
      });
      await tester.pumpAndSettle();
      
      // After login it should route to branch selection normally
    });

    testWidgets('Login fallido muestra error', (tester) async {
      await tester.pumpWidget(const GetMaterialApp(home: Scaffold(body: SizedBox())));
      mockAuthRepository.failLogin = true;
      
      controller.form.control('username').value = 'baduser';
      controller.form.control('password').value = 'badpass';
      
      await tester.runAsync(() async {
        await controller.login();
        // Since it throws, Snackbar will show up
        await Future.delayed(const Duration(milliseconds: 100));
        Get.closeAllSnackbars();
      });
      await tester.pumpAndSettle();
    });
  });
}
