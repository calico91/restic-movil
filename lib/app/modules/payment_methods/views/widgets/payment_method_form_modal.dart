import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:reactive_forms/reactive_forms.dart';
import 'package:restic_movil/app/data/models/payment_method_model.dart';
import 'package:restic_movil/app/modules/payment_methods/controllers/payment_methods_controller.dart';
import 'package:restic_movil/core/utils/buttons/custom_submit_button.dart';
import 'package:restic_movil/core/utils/inputs/custom_text_field.dart';

class PaymentMethodFormModal extends GetView<PaymentMethodsController> {
  final PaymentMethodModel method;

  const PaymentMethodFormModal({super.key, required this.method});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        top: 24,
        left: 24,
        right: 24,
      ),
      child: SafeArea(
        child: SingleChildScrollView(
          child: ReactiveForm(
            formGroup: controller.form,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Editar Método de Pago',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF0D47A1),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Get.back(),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                const CustomReactiveTextField<String>(
                  formControlName: 'method',
                  labelText: 'Código Interno (Solo Lectura)',
                  readOnly: true,
                ),
                const SizedBox(height: 20),
                CustomReactiveTextField<String>(
                  formControlName: 'displayName',
                  labelText: 'Nombre a Mostrar',
                  validationMessages: {
                    ValidationMessage.required: (_) =>
                        'Este campo es requerido',
                    ValidationMessage.maxLength: (_) => 'Máximo 80 caracteres',
                  },
                ),
                const SizedBox(height: 20),
                ReactiveSwitchListTile(
                  formControlName: 'active',
                  title: const Text(
                    'Método Activo',
                    style: TextStyle(fontWeight: FontWeight.w500),
                  ),
                  activeColor: const Color(0xFF0D47A1),
                  contentPadding: EdgeInsets.zero,
                ),
                const SizedBox(height: 20),
                CustomReactiveTextField<int>(
                  formControlName: 'displayOrder',
                  labelText: 'Orden de Aparición',
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  validationMessages: {
                    ValidationMessage.required: (_) =>
                        'Este campo es requerido',
                    ValidationMessage.min: (_) => 'El valor mínimo es 1',
                  },
                ),
                const SizedBox(height: 30),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: CustomSubmitButton(
                    text: 'Guardar Cambios',
                    onPressed: controller.updateMethod,
                    backgroundColor: const Color(0xFF0D47A1),
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
