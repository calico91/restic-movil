import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:reactive_forms/reactive_forms.dart';
import 'package:restic_movil/app/data/repositories/auth_repository.dart';
import 'package:restic_movil/app/data/services/storage_service.dart';
import 'package:restic_movil/app/data/models/login_response.dart';
import 'package:restic_movil/app/routes/app_routes.dart';
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
            final LoginResponse response = await authRepository.login(
              username,
              password,
            );

            await storageService.saveToken(response.token!);
            return response;

          } catch (e) {
            final String errorMessage = ExceptionHandler.extractMessage(e);
            Get.showSnackbar(ErrorSnackbar(errorMessage));
          }
          return null;
        },
        loadingWidget: LoadingCharging(),
      ).then((response) async {
        if (response != null) {
          if (response.branches != null && response.branches!.isNotEmpty) {
            if (response.branches!.length == 1) {
              await storageService.saveBranchId(response.branches!.first.id!);
              Get.offAllNamed(Routes.HOME);
            } else {
              _showBranchSelectionModal(response.branches!);
            }
          } else {
            Get.offAllNamed(Routes.HOME);
          }
        }
      });
    } else {
      form.markAllAsTouched();
    }
  }

  void _showBranchSelectionModal(List<Branch> branches) {
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(16),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Seleccione una sucursal',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Flexible(
              child: ListView.separated(
                shrinkWrap: true,
                itemCount: branches.length,
                separatorBuilder: (_, __) => const Divider(),
                itemBuilder: (context, index) {
                  final branch = branches[index];
                  return ListTile(
                    leading: const Icon(Icons.store, color: Colors.blue),
                    title: Text(branch.name ?? 'Sucursal sin nombre'),
                    onTap: () async {
                      if (branch.id != null) {
                        await storageService.saveBranchId(branch.id!);
                        if (Get.isBottomSheetOpen ?? false) {
                          Get.back();
                        }
                        Get.offAllNamed(Routes.HOME);
                      }
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
      isDismissible: false,
      enableDrag: false,
    );
  }
}
