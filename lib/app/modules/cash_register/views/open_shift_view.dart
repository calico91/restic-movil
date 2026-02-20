import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:restic_movil/core/utils/formatters/thousands_separator_input_formatter.dart';
import 'package:restic_movil/core/utils/widgets/custom_scaffold.dart';
import 'package:restic_movil/app/modules/cash_register/controllers/open_shift_controller.dart';
import 'package:reactive_forms/reactive_forms.dart';

class OpenShiftView extends GetView<OpenShiftController> {
  const OpenShiftView({super.key});

  @override
  Widget build(BuildContext context) {
    return CustomScaffold(
      title: 'Opciones de Caja',
      body: Obx(
        () => ReactiveForm(
          formGroup: controller.form,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Apertura de Caja',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 20),
                ReactiveDropdownField<String>(
                  formControlName: 'cashierId',
                  validationMessages: {
                    ValidationMessage.required: (error) => 'Requerido',
                  },
                  decoration: const InputDecoration(
                    labelText: 'Usuario',
                    border: OutlineInputBorder(),
                  ),
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
                ReactiveTextField<String>(
                  formControlName: 'initialAmount',
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    ThousandsSeparatorInputFormatter(),
                  ],
                  decoration: const InputDecoration(
                    labelText: 'Monto Inicial (COP)',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.attach_money),
                  ),
                  validationMessages: {
                    ValidationMessage.required: (error) =>
                        'El monto es requerido',
                    ValidationMessage.min: (error) =>
                        'El monto debe ser positivo',
                  },
                ),
                const SizedBox(height: 16),
                ReactiveDropdownField<String>(
                  formControlName: 'terminalId',
                  validationMessages: {
                    ValidationMessage.required: (error) => 'Requerido',
                  },
                  decoration: const InputDecoration(
                    labelText: 'Terminal',
                    border: OutlineInputBorder(),
                  ),
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
                ReactiveTextField(
                  formControlName: 'remarks',
                  maxLines: 3,
                  decoration: const InputDecoration(
                    labelText: 'Observaciones (Opcional)',
                    border: OutlineInputBorder(),
                    helperText: 'Máximo 250 caracteres',
                  ),
                  validationMessages: {
                    ValidationMessage.maxLength: (error) =>
                        'Máximo 250 caracteres permitidos',
                  },
                ),
                const SizedBox(height: 32),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: controller.submit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: const Text('ENVIAR'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
