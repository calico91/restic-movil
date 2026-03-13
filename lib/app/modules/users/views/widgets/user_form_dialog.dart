import 'package:flutter/material.dart';
import 'package:reactive_forms/reactive_forms.dart';
import 'package:restic_movil/app/data/models/login_response.dart';
import 'package:restic_movil/app/data/models/user_model.dart';
import 'package:restic_movil/core/utils/inputs/custom_text_field.dart';

import 'package:restic_movil/core/utils/modals/custom_form_dialog.dart';

class UserFormDialog extends StatelessWidget {
  final UserModel? user;
  final List<UserRole> roles;
  final Function(Map<String, dynamic>) onSubmit;

  const UserFormDialog({
    super.key,
    this.user,
    required this.roles,
    required this.onSubmit,
  });

  @override
  Widget build(BuildContext context) {
    final form = FormGroup({
      'username': FormControl<String>(
        value: user?.username,
        validators: [Validators.required, Validators.maxLength(50)],
      ),
      'name': FormControl<String>(
        value: user?.name,
        validators: [Validators.required, Validators.maxLength(50)],
      ),
      'secondName': FormControl<String>(
        value: user?.secondName,
        validators: [Validators.maxLength(50)],
      ),
      'lastName': FormControl<String>(
        value: user?.lastName,
        validators: [Validators.required, Validators.maxLength(50)],
      ),
      'secondLastName': FormControl<String>(
        value: user?.secondLastName,
        validators: [Validators.maxLength(50)],
      ),
      'mobileNumber': FormControl<String>(
        value: user?.mobileNumber,
        validators: [Validators.required, Validators.maxLength(20)],
      ),
      'email': FormControl<String>(
        value: user?.email,
        validators: [
          Validators.required,
          Validators.email,
          Validators.maxLength(80),
        ],
      ),
      'password': FormControl<String>(
        validators: user == null
            ? [Validators.required, Validators.minLength(6)]
            : [Validators.minLength(6)],
      ),
      'isActive': FormControl<bool>(
        value: user?.isActive ?? true,
        validators: [Validators.required],
      ),
      'roles': FormArray<String>(
        user?.roles.map((r) => FormControl<String>(value: r)).toList() ?? [],
        validators: [Validators.required, Validators.minLength(1)],
      ),
    });

    return CustomFormDialog(
      title: user == null ? 'Nuevo Usuario' : 'Editar Usuario',
      formGroup: form,
      onSave: () {
        final data = Map<String, dynamic>.from(form.value);

        // Remove password if it is empty (only possible on updates)
        if (data['password'] == null || (data['password'] as String).isEmpty) {
          data.remove('password');
        }

        // Transform FormArray to Set/List
        final rolesData = form.control('roles').value as List?;
        data['roles'] = rolesData?.whereType<String>().toList() ?? [];

        onSubmit(data);
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CustomReactiveTextField<String>(
            formControlName: 'username',
            labelText: 'Usuario *',
            validationMessages: {
              'required': (error) => 'Requerido',
              'maxLength': (error) => 'Máximo 50 caracteres',
            },
          ),
          const SizedBox(height: 12),
          CustomReactiveTextField<String>(
            formControlName: 'name',
            labelText: 'Primer Nombre *',
            validationMessages: {
              'required': (error) => 'Requerido',
              'maxLength': (error) => 'Máximo 50 caracteres',
            },
          ),
          const SizedBox(height: 12),
          CustomReactiveTextField<String>(
            formControlName: 'secondName',
            labelText: 'Segundo Nombre',
            validationMessages: {
              'maxLength': (error) => 'Máximo 50 caracteres',
            },
          ),
          const SizedBox(height: 12),
          CustomReactiveTextField<String>(
            formControlName: 'lastName',
            labelText: 'Primer Apellido *',
            validationMessages: {
              'required': (error) => 'Requerido',
              'maxLength': (error) => 'Máximo 50 caracteres',
            },
          ),
          const SizedBox(height: 12),
          CustomReactiveTextField<String>(
            formControlName: 'secondLastName',
            labelText: 'Segundo Apellido',
            validationMessages: {
              'maxLength': (error) => 'Máximo 50 caracteres',
            },
          ),
          const SizedBox(height: 12),
          CustomReactiveTextField<String>(
            formControlName: 'mobileNumber',
            labelText: 'Número Móvil *',
            keyboardType: TextInputType.phone,
            validationMessages: {
              'required': (error) => 'Requerido',
              'maxLength': (error) => 'Máximo 20 caracteres',
            },
          ),
          const SizedBox(height: 12),
          CustomReactiveTextField<String>(
            formControlName: 'email',
            labelText: 'Correo Electrónico *',
            keyboardType: TextInputType.emailAddress,
            validationMessages: {
              'required': (error) => 'Requerido',
              'email': (error) => 'Formato inválido',
              'maxLength': (error) => 'Máximo 80 caracteres',
            },
          ),
          const SizedBox(height: 12),
          CustomReactiveTextField<String>(
            formControlName: 'password',
            labelText: user == null ? 'Contraseña *' : 'Contraseña (Opcional)',
            obscureText: true,
            validationMessages: {
              'required': (error) => 'Requerido',
              'minLength': (error) => 'Mínimo 6 caracteres',
            },
          ),
          const SizedBox(height: 12),
          ReactiveSwitchListTile(
            formControlName: 'isActive',
            title: const Text('Activo'),
          ),
          const SizedBox(height: 12),
          const Text('Roles *', style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          ReactiveFormArray<String>(
            formArrayName: 'roles',
            builder: (context, formArray, child) {
              return Column(
                children: roles.map((role) {
                  final isSelected = formArray.controls.any(
                    (c) => c.value == role.name,
                  );
                  return CheckboxListTile(
                    title: Text(role.name ?? ''),
                    value: isSelected,
                    onChanged: (bool? checked) {
                      if (checked == true) {
                        formArray.add(FormControl<String>(value: role.name));
                      } else {
                        final index = formArray.controls.indexWhere(
                          (c) => c.value == role.name,
                        );
                        if (index != -1) {
                          formArray.removeAt(index);
                        }
                      }
                      formArray.markAsTouched();
                    },
                  );
                }).toList(),
              );
            },
          ),
          ReactiveFormConsumer(
            builder: (context, formGroup, child) {
              if (formGroup.control('roles').touched &&
                  formGroup.control('roles').invalid) {
                return const Padding(
                  padding: EdgeInsets.only(top: 8.0),
                  child: Text(
                    'Debe seleccionar al menos un rol',
                    style: TextStyle(color: Colors.red, fontSize: 12),
                  ),
                );
              }
              return const SizedBox.shrink();
            },
          ),
        ],
      ),
    );
  }
}
