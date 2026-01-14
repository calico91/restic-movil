import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';
import 'package:reactive_forms/reactive_forms.dart';
import 'package:restic_movil/app/data/repositories/auth_repository.dart';
import 'package:restic_movil/app/data/services/storage_service.dart';
import 'package:restic_movil/core/utils/snackbars/error_snackbar.dart';
import 'package:restic_movil/core/utils/snackbars/info_snackbar.dart';

class LoginController extends GetxController {
  final AuthRepository authRepository;
  final StorageService storageService;

  LoginController({required this.authRepository, required this.storageService});

  final form = FormGroup({
    'username': FormControl<String>(
      validators: [Validators.required],
      value: 'super',
    ),
    'password': FormControl<String>(
      validators: [Validators.required],
      value: 'Golpi25*',
    ),
  });

  final RxString selectedRole = 'Administrador'.obs;
  final List<String> roles = ['Administrador', 'Mesero', 'Cocinero'];

  void selectRole(String role) {
    selectedRole.value = role;
  }

  Future<void> login() async {
    if (form.valid) {
      final username = form.control('username').value as String;
      final password = form.control('password').value as String;

      Get.showOverlay(
        asyncFunction: () async {
          try {
            final response = await authRepository.login(username, password);

            if (response.token != null) {
              await storageService.saveToken(response.token!);

              Get.showSnackbar(InfoSnackbar('Bienvenido ${response.name}'));
              // Get.offAllNamed(Routes.HOME);
            }
          } catch (e) {
            String errorMessage = e.toString();

            try {
              errorMessage = (e as dynamic).message;
            } catch (_) {}

            Get.showSnackbar(ErrorSnackbar(errorMessage));
          }
        },
        loadingWidget: Center(
          child: Container(
            width: 150,
            height: 150,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Lottie.network(
              'https://lottie.host/953046d7-8461-4c6e-821b-17865267339d/G4o3i9qR1l.json',
              fit: BoxFit.contain,
            ),
          ),
        ),
      );
    } else {
      form.markAllAsTouched();
    }
  }
}
