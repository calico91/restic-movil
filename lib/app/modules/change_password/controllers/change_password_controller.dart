import 'package:get/get.dart';
import 'package:reactive_forms/reactive_forms.dart';
import 'package:restic_movil/app/data/services/storage_service.dart';
import 'package:restic_movil/app/modules/auth/views/widgets/branch_selection_modal.dart';
import 'package:restic_movil/app/modules/profile/repositories/profile_repository.dart';
import 'package:restic_movil/app/routes/app_routes.dart';
import 'package:restic_movil/core/utils/animations/loading_charging.dart';
import 'package:restic_movil/core/utils/helpers/error_handler.dart';

class ChangePasswordController extends GetxController {
  final ProfileRepository repository = Get.find<ProfileRepository>();
  final StorageService storageService = Get.find<StorageService>();

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
    'confirmNewPassword': FormControl<String>(
      validators: [Validators.required],
    ),
  });

  final RxBool isCurrentPasswordVisible = false.obs;
  final RxBool isNewPasswordVisible = false.obs;

  void toggleCurrentPasswordVisibility() {
    isCurrentPasswordVisible.value = !isCurrentPasswordVisible.value;
  }

  void toggleNewPasswordVisible() {
    isNewPasswordVisible.value = !isNewPasswordVisible.value;
  }

  Future<void> submit() async {
    if (form.invalid) {
      form.markAllAsTouched();
      return;
    }

    final values = form.value;
    final currentPassword = values['currentPassword'] as String;
    final newPassword = values['newPassword'] as String;
    final confirmNewPassword = values['confirmNewPassword'] as String;

    if (newPassword != confirmNewPassword) {
      ErrorHandler.showErrorDialog('Las contrasenas no coinciden');
      return;
    }

    await Get.showOverlay(
      loadingWidget: const LoadingCharging(),
      asyncFunction: () async {
        try {
          await repository.changeMyPassword(currentPassword, newPassword);
          _navigateAfterChange();
        } catch (e) {
          ErrorHandler.showErrorDialog(e);
        }
      },
    );
  }

  void _navigateAfterChange() async {
    final response = await storageService.getUser();
    if (response != null && response.branches != null && response.branches!.isNotEmpty) {
      if (response.branches!.length == 1) {
        await storageService.saveBranchId(response.branches!.first.id!);
        Get.offAllNamed(Routes.HOME);
      } else {
        BranchSelectionModal.show(response.branches!, storageService);
      }
    } else {
      Get.offAllNamed(Routes.HOME);
    }
  }
}
