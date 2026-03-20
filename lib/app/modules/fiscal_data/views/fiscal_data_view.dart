import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:reactive_forms/reactive_forms.dart';
import 'package:restic_movil/app/modules/fiscal_data/controllers/fiscal_data_controller.dart';
import 'package:restic_movil/core/utils/widgets/custom_scaffold.dart';
import 'package:restic_movil/core/utils/inputs/custom_text_field.dart';
import 'package:restic_movil/core/utils/inputs/custom_dropdown_field.dart';
import 'package:restic_movil/core/utils/buttons/custom_submit_button.dart';

class FiscalDataView extends GetView<FiscalDataController> {
  const FiscalDataView({super.key});

  @override
  Widget build(BuildContext context) {
    return CustomScaffold(
      title: 'Datos Fiscales',
      showBackButton: true,
      resizeToAvoidBottomInset: true,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: ReactiveForm(
          formGroup: controller.form,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Información de Facturación',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF0D47A1), // Deep Blue
                ),
              ),
              const SizedBox(height: 16),
              CustomReactiveTextField<String>(
                formControlName: 'businessName',
                labelText: 'Razón Social *',
                validationMessages: {
                  ValidationMessage.required: (error) =>
                      'La razón social es obligatoria',
                },
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    flex: 3,
                    child: CustomReactiveTextField<String>(
                      formControlName: 'taxId',
                      labelText: 'NIT (Sin dígito) *',
                      keyboardType: TextInputType.number,
                      validationMessages: {
                        ValidationMessage.required: (error) =>
                            'El NIT es obligatorio',
                        ValidationMessage.pattern: (error) =>
                            'Solo debe contener números',
                        ValidationMessage.minLength: (error) =>
                            'Mínimo 6 dígitos',
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    flex: 1,
                    child: CustomReactiveTextField<String>(
                      formControlName: 'taxIdDigit',
                      labelText: 'DV',
                      keyboardType: TextInputType.number,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              CustomReactiveTextField<String>(
                formControlName: 'dianResolution',
                labelText: 'Resolución DIAN *',
                validationMessages: {
                  ValidationMessage.required: (error) =>
                      'La resolución es obligatoria',
                },
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: CustomReactiveTextField<String>(
                      formControlName: 'invoicePrefix',
                      labelText: 'Prefijo (Ej: FE)',
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: CustomReactiveTextField<int>(
                      formControlName: 'resolutionNumberFrom',
                      labelText: 'Desde',
                      keyboardType: TextInputType.number,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: CustomReactiveTextField<int>(
                      formControlName: 'resolutionNumberTo',
                      labelText: 'Hasta',
                      keyboardType: TextInputType.number,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              CustomReactiveDropdownField<String>(
                formControlName: 'taxRegime',
                labelText: 'Régimen Tributario *',
                items: controller.taxRegimes.map((regime) {
                  return DropdownMenuItem(
                    value: regime,
                    child: Text(regime.replaceAll('_', ' ')),
                  );
                }).toList(),
                validationMessages: {
                  ValidationMessage.required: (error) =>
                      'El régimen es obligatorio',
                },
              ),
              const SizedBox(height: 16),
              const Divider(),
              const SizedBox(height: 16),
              const Text(
                'Información de Contacto',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF0D47A1),
                ),
              ),
              const SizedBox(height: 16),
              CustomReactiveTextField<String>(
                formControlName: 'email',
                labelText: 'Correo Electrónico *',
                keyboardType: TextInputType.emailAddress,
                validationMessages: {
                  ValidationMessage.required: (error) =>
                      'El correo es obligatorio',
                  ValidationMessage.email: (error) =>
                      'Ingrese un correo válido',
                },
              ),
              const SizedBox(height: 16),
              CustomReactiveTextField<String>(
                formControlName: 'phone',
                labelText: 'Teléfono',
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 16),
              CustomReactiveTextField<String>(
                formControlName: 'address',
                labelText: 'Dirección Fiscal *',
                validationMessages: {
                  ValidationMessage.required: (error) =>
                      'La dirección es obligatoria',
                },
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: CustomReactiveTextField<String>(
                      formControlName: 'city',
                      labelText: 'Ciudad *',
                      validationMessages: {
                        ValidationMessage.required: (error) =>
                            'La ciudad es obligatoria',
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: CustomReactiveTextField<String>(
                      formControlName: 'department',
                      labelText: 'Departamento',
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),
              Obx(
                () => CustomSubmitButton(
                  text: controller.isEditing.value
                      ? 'Actualizar Datos'
                      : 'Guardar Datos',
                  onPressed: controller.submit,
                ),
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}
