import 'package:flutter/material.dart';
import 'package:reactive_forms/reactive_forms.dart';
import 'package:restic_movil/core/utils/inputs/custom_text_field.dart';
import 'package:restic_movil/core/utils/modals/custom_form_dialog.dart';

class CustomerFormDialog extends StatelessWidget {
  final bool isEditing;
  final FormGroup form;
  final VoidCallback onSubmit;

  const CustomerFormDialog({
    super.key,
    required this.isEditing,
    required this.form,
    required this.onSubmit,
  });

  @override
  Widget build(BuildContext context) {
    return CustomFormDialog(
      title: isEditing ? 'Editar Cliente' : 'Crear Cliente',
      formGroup: form,
      onSave: onSubmit,
      child: Column(
        children: [
          CustomReactiveTextField<String>(
            formControlName: 'name',
            labelText: 'Nombre *',
            validationMessages: {
              ValidationMessage.required: (error) => 'El nombre es obligatorio',
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
        ],
      ),
    );
  }
}
