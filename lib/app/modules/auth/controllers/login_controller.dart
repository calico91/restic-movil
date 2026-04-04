import 'package:get/get.dart';
import 'package:reactive_forms/reactive_forms.dart';
import 'package:restic_movil/app/data/repositories/auth_repository.dart';
import 'package:restic_movil/app/data/services/storage_service.dart';
import 'package:restic_movil/app/data/models/login_response.dart';
import 'package:restic_movil/app/routes/app_routes.dart';
import 'package:restic_movil/core/utils/animations/loading_charging.dart';
import 'package:restic_movil/core/utils/helpers/exception_handler.dart';
import 'package:restic_movil/core/utils/snackbars/error_snackbar.dart';
import 'package:restic_movil/app/modules/auth/views/widgets/branch_selection_modal.dart';
import 'package:restic_movil/app/modules/auth/views/widgets/configure_connection_modal.dart';

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

  void configureConnection() {
    ConfigureConnectionModal.show(storageService);
  }

  Future<void> login() async {
    final serverUrl = await storageService.getServerUrl();
    if (serverUrl == null || serverUrl.isEmpty) {
      Get.showSnackbar(
        const ErrorSnackbar('Debe configurar la conexión antes de ingresar.'),
      );
      return;
    }

    if (form.valid) {
      final username = form.control('username').value as String;
      final password = form.control('password').value as String;

      await Get.showOverlay(
        loadingWidget: LoadingCharging(),
        asyncFunction: () async {
          try {
            final LoginResponse response = await authRepository.login(
              username,
              password,
            );

            await storageService.saveToken(response.token!);
            await storageService.saveUser(response);
            return response;
          } catch (e) {
            final String errorMessage = ExceptionHandler.extractMessage(e);
            final String recomendations = ExceptionHandler.extractMessage(
              e,
              attribute: 'recommendation',
            );

            Get.showSnackbar(ErrorSnackbar(errorMessage + recomendations));
          }
        },
      ).then((response) async {
        /* 
        si el usuario tiene una sola sucursal, se guarda y se navega al home
        si tiene mas de una sucursal, se muestra el modal para seleccionar
        si no tiene sucursales, se muestra un error
        */
        if (response == null) return;

        if (response.branches!.length == 1) {
          await storageService.saveBranchId(response.branches!.first.id!);
          Get.offAllNamed(Routes.HOME);
        } else {
          BranchSelectionModal.show(response.branches!, storageService);
        }
      });
    } else {
      form.markAllAsTouched();
    }
  }
}
