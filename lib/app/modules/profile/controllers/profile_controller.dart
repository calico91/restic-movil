import 'package:get/get.dart';
import 'package:reactive_forms/reactive_forms.dart';
import 'package:restic_movil/core/utils/animations/loading_charging.dart';
import 'package:restic_movil/core/utils/helpers/error_handler.dart';
import 'package:restic_movil/core/utils/snackbars/info_snackbar.dart';
import 'package:restic_movil/app/modules/profile/repositories/profile_repository.dart';

class ProfileController extends GetxController {
  final ProfileRepository repository;

  ProfileController(this.repository);

  final form = FormGroup({
    'currentPassword': FormControl<String>(
      validators: [Validators.required],
    ),
    'newPassword': FormControl<String>(
      validators: [
        Validators.required,
        Validators.minLength(6),
        Validators.maxLength(100),
      ],
    ),
  });

  final RxBool isCurrentPasswordVisible = false.obs;
  final RxBool isNewPasswordVisible = false.obs;

  void toggleCurrentPasswordVisibility() {
    isCurrentPasswordVisible.value = !isCurrentPasswordVisible.value;
  }

  void toggleNewPasswordVisibility() {
    isNewPasswordVisible.value = !isNewPasswordVisible.value;
  }

  Future<void> changePassword() async {
    if (form.invalid) {
      form.markAllAsTouched();
      return;
    }

    final values = form.value;
    final currentPassword = values['currentPassword'] as String;
    final newPassword = values['newPassword'] as String;

    Get.showOverlay(
      loadingWidget: const LoadingCharging(),
      asyncFunction: () async {
        try {
          await repository.changeMyPassword(currentPassword, newPassword);
          form.reset();
          Get.showSnackbar(const InfoSnackbar('Contraseña cambiada exitosamente'));
        } catch (e) {
          ErrorHandler.showErrorDialog(e);
        }
      },
    );
  }
}
