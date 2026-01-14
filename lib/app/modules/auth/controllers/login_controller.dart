import 'package:get/get.dart';
import 'package:reactive_forms/reactive_forms.dart';
import 'package:restic_movil/app/data/repositories/auth_repository.dart';
import 'package:restic_movil/app/data/services/storage_service.dart';
import 'package:restic_movil/core/utils/animations/loading_charging.dart';
import 'package:restic_movil/core/utils/helpers/exception_handler.dart';
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
            final String errorMessage = ExceptionHandler.extractMessage(e);
            Get.showSnackbar(ErrorSnackbar(errorMessage));
          }
        },
        loadingWidget: LoadingCharging(),
      );
    } else {
      form.markAllAsTouched();
    }
  }
}
