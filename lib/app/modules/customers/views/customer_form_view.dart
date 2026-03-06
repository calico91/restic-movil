import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:reactive_forms/reactive_forms.dart';
import 'package:restic_movil/app/modules/customers/controllers/customer_controller.dart';
import 'package:restic_movil/core/utils/widgets/custom_scaffold.dart';
import 'package:restic_movil/core/utils/buttons/custom_submit_button.dart';
import 'package:restic_movil/core/utils/inputs/custom_text_field.dart';

class CustomerFormView extends GetView<CustomerController> {
  const CustomerFormView({super.key});

  @override
  Widget build(BuildContext context) {
    return CustomScaffold(
      title: controller.isEditing.value ? 'Editar Cliente' : 'Crear Cliente',
      showBackButton: true,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: ReactiveForm(
          formGroup: controller.form,
          child: Column(
            children: [
              CustomReactiveTextField<String>(
                formControlName: 'name',
                labelText: 'Nombre *',
                validationMessages: {
                  ValidationMessage.required: (error) =>
                      'El nombre es obligatorio',
                },
              ),
              const SizedBox(height: 16),
              const CustomReactiveTextField<String>(
                formControlName: 'lastName',
                labelText: 'Apellido',
              ),
              const SizedBox(height: 16),
              CustomReactiveTextField<String>(
                formControlName: 'document',
                labelText: 'Documento',
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 16),
              CustomReactiveTextField<String>(
                formControlName: 'phone',
                labelText: 'Teléfono *',
                keyboardType: TextInputType.phone,
                validationMessages: {
                  ValidationMessage.required: (error) =>
                      'El teléfono es obligatorio',
                },
              ),
              const SizedBox(height: 16),
              CustomReactiveTextField<String>(
                formControlName: 'email',
                labelText: 'Email',
                keyboardType: TextInputType.emailAddress,
                validationMessages: {
                  ValidationMessage.email: (error) => 'Ingrese un email válido',
                },
              ),
              const SizedBox(height: 16),
              const CustomReactiveTextField<String>(
                formControlName: 'address',
                labelText: 'Dirección',
              ),
              const SizedBox(height: 16),
              const CustomReactiveTextField<String>(
                formControlName: 'notes',
                labelText: 'Notas',
                maxLines: 3,
              ),
              const SizedBox(height: 24),
              ReactiveFormConsumer(
                builder: (context, form, child) {
                  return CustomSubmitButton(
                    text: controller.isEditing.value ? 'Actualizar' : 'Crear',
                    onPressed: form.valid ? controller.submit : null,
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
