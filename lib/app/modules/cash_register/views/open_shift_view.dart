import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:restic_movil/core/utils/formatters/thousands_separator_input_formatter.dart';
import 'package:restic_movil/core/utils/widgets/custom_scaffold.dart';
import 'package:restic_movil/app/modules/cash_register/controllers/open_shift_controller.dart';
import 'package:reactive_forms/reactive_forms.dart';
import 'package:restic_movil/core/utils/buttons/custom_submit_button.dart';
import 'package:restic_movil/core/utils/inputs/custom_text_field.dart';
import 'package:restic_movil/core/utils/inputs/custom_dropdown_field.dart';

class OpenShiftView extends GetView<OpenShiftController> {
  const OpenShiftView({super.key});

  @override
  Widget build(BuildContext context) {
    return CustomScaffold(
      title: 'Apertura de Caja',
      body: Obx(
        () => ReactiveForm(
          formGroup: controller.form,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 20),
                CustomReactiveDropdownField<String>(
                  formControlName: 'cashierId',
                  labelText: 'Usuario',
                  validationMessages: {
                    ValidationMessage.required: (error) => 'Requerido',
                  },
                  items: controller.users
                      .map(
                        (user) => DropdownMenuItem(
                          value: user.id,
                          child: Text(user.fullName),
                        ),
                      )
                      .toList(),
                ),
                const SizedBox(height: 16),
                CustomReactiveTextField<String>(
                  formControlName: 'initialAmount',
                  labelText: 'Monto Inicial (COP)',
                  keyboardType: TextInputType.number,
                  inputFormatters: [ThousandsSeparatorInputFormatter()],
                  prefixIcon: const Icon(Icons.attach_money),
                  validationMessages: {
                    ValidationMessage.required: (error) =>
                        'El monto es requerido',
                    ValidationMessage.min: (error) =>
                        'El monto debe ser positivo',
                  },
                ),
                const SizedBox(height: 16),
                CustomReactiveDropdownField<String>(
                  formControlName: 'terminalId',
                  labelText: 'Terminal',
                  validationMessages: {
                    ValidationMessage.required: (error) => 'Requerido',
                  },
                  items: controller.terminals
                      .map(
                        (terminal) => DropdownMenuItem(
                          value: terminal.id,
                          child: Text(terminal.name),
                        ),
                      )
                      .toList(),
                ),
                const SizedBox(height: 16),
                CustomReactiveTextField<String>(
                  formControlName: 'remarks',
                  labelText: 'Observaciones (Opcional)',
                  maxLines: 3,
                  hintText: 'Máximo 250 caracteres',
                  validationMessages: {
                    ValidationMessage.maxLength: (error) =>
                        'Máximo 250 caracteres permitidos',
                  },
                ),
                const SizedBox(height: 32),
                ReactiveFormConsumer(
                  builder: (context, form, child) {
                    return CustomSubmitButton(
                      text: 'ENVIAR',
                      onPressed: form.valid ? controller.submit : null,
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
