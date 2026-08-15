import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:reactive_forms/reactive_forms.dart';
import 'package:restic_movil/app/modules/change_password/controllers/change_password_controller.dart';

class ChangePasswordView extends GetView<ChangePasswordController> {
  const ChangePasswordView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Card(
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: ReactiveForm(
                  formGroup: controller.form,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const Icon(Icons.lock_outline, size: 64, color: Color(0xFF0D47A1)),
                      const SizedBox(height: 16),
                      const Text(
                        'Cambio de contrasena obligatorio',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Por seguridad, debes cambiar tu contrasena antes de continuar.',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.grey),
                      ),
                      const SizedBox(height: 24),
                      Obx(() => ReactiveTextField(
                            formControlName: 'currentPassword',
                            obscureText: !controller.isCurrentPasswordVisible.value,
                            decoration: InputDecoration(
                              labelText: 'Contrasena actual',
                              border: const OutlineInputBorder(),
                              suffixIcon: IconButton(
                                icon: Icon(controller.isCurrentPasswordVisible.value
                                    ? Icons.visibility_off
                                    : Icons.visibility),
                                onPressed: controller.toggleCurrentPasswordVisibility,
                              ),
                            ),
                          )),
                      const SizedBox(height: 16),
                      Obx(() => ReactiveTextField(
                            formControlName: 'newPassword',
                            obscureText: !controller.isNewPasswordVisible.value,
                            decoration: InputDecoration(
                              labelText: 'Nueva contrasena',
                              border: const OutlineInputBorder(),
                              suffixIcon: IconButton(
                                icon: Icon(controller.isNewPasswordVisible.value
                                    ? Icons.visibility_off
                                    : Icons.visibility),
                                onPressed: controller.toggleNewPasswordVisible,
                              ),
                            ),
                          )),
                      const SizedBox(height: 16),
                      Obx(() => ReactiveTextField(
                            formControlName: 'confirmNewPassword',
                            obscureText: !controller.isNewPasswordVisible.value,
                            decoration: const InputDecoration(
                              labelText: 'Confirmar nueva contrasena',
                              border: OutlineInputBorder(),
                            ),
                          )),
                      const SizedBox(height: 24),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF0D47A1),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                        onPressed: controller.submit,
                        child: const Text(
                          'Cambiar contrasena',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
