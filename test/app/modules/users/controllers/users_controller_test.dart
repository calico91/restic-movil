import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:restic_movil/app/modules/users/controllers/users_controller.dart';
import 'package:restic_movil/app/data/repositories/users_repository.dart';
import 'package:restic_movil/app/data/models/user_model.dart';
import 'package:restic_movil/core/utils/animations/loading_charging.dart';

class MockUsersRepository extends Fake implements UsersRepository {
  @override Future<List<UserModel>> getUsers() async => [];
  @override Future<List<UserRole>> getRoles() async => [];
}

void main() {
  group('UsersController Test - Usuarios', () {
    late UsersController controller;

    setUp(() {
      Get.testMode = true;
      Get.reset();
    });

    testWidgets('Carga inicial de usuarios', (tester) async {
      await tester.pumpWidget(const GetMaterialApp(home: Scaffold(body: SizedBox())));
      
      controller = UsersController(MockUsersRepository());
      Get.put(controller);
      
      await tester.runAsync(() async {
        await Future.delayed(const Duration(milliseconds: 100));
        Get.closeAllSnackbars();
      });
      await tester.pumpAndSettle();
      
      expect(controller.users.length, 0);
      expect(controller.roles.length, 0);
    });
  });
}
