import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:reactive_forms/reactive_forms.dart';
import 'package:restic_movil/app/modules/profile/controllers/profile_controller.dart';
import 'package:restic_movil/core/utils/buttons/custom_submit_button.dart';
import 'package:restic_movil/core/utils/inputs/custom_text_field.dart';
import 'package:restic_movil/core/utils/widgets/custom_scaffold.dart';

class ProfileView extends GetView<ProfileController> {
  const ProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    return CustomScaffold(
      title: 'Mi Perfil',
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Center(
              child:  Text(
                'Cambiar Contraseña',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF0D47A1),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: ReactiveForm(
                  formGroup: controller.form,
                  child: Column(
                    children: [
                      Obx(
                        () => CustomReactiveTextField<String>(
                          formControlName: 'currentPassword',
                          labelText: 'Contraseña Actual',
                          obscureText:
                              !controller.isCurrentPasswordVisible.value,
                          inputFormatters: [FilteringTextInputFormatter.deny(RegExp(r'\s'))],
                          suffixIcon: IconButton(
                            icon: Icon(
                              controller.isCurrentPasswordVisible.value
                                  ? Icons.visibility
                                  : Icons.visibility_off,
                              color: Colors.grey,
                            ),
                            onPressed:
                                controller.toggleCurrentPasswordVisibility,
                          ),
                          validationMessages: {
                            ValidationMessage.required: (_) =>
                                'Este campo es requerido',
                          },
                        ),
                      ),
                      const SizedBox(height: 20),
                      Obx(
                        () => CustomReactiveTextField<String>(
                          formControlName: 'newPassword',
                          labelText: 'Nueva Contraseña',
                          obscureText: !controller.isNewPasswordVisible.value,
                          hintText: 'Mínimo 6 caracteres',
                          inputFormatters: [FilteringTextInputFormatter.deny(RegExp(r'\s'))],
                          suffixIcon: IconButton(
                            icon: Icon(
                              controller.isNewPasswordVisible.value
                                  ? Icons.visibility
                                  : Icons.visibility_off,
                              color: Colors.grey,
                            ),
                            onPressed: controller.toggleNewPasswordVisibility,
                          ),
                          validationMessages: {
                            ValidationMessage.required: (_) =>
                                'Este campo es requerido',
                            ValidationMessage.minLength: (_) =>
                                'Debe tener al menos 6 caracteres',
                            ValidationMessage.maxLength: (_) =>
                                'Máximo 100 caracteres',
                          },
                        ),
                      ),
                      const SizedBox(height: 30),
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: CustomSubmitButton(
                          text: 'Actualizar Contraseña',
                          onPressed: controller.changePassword,
                          backgroundColor: const Color(0xFF0D47A1),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
