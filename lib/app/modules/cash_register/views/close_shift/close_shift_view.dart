import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:reactive_forms/reactive_forms.dart';
import 'package:restic_movil/app/modules/cash_register/controllers/close_shift/close_shift_controller.dart';
import 'package:restic_movil/core/utils/formatters/thousands_separator_input_formatter.dart';
import 'package:restic_movil/core/utils/modals/modal_info.dart';
import 'package:restic_movil/core/utils/widgets/custom_scaffold.dart';
import 'package:restic_movil/core/utils/buttons/custom_submit_button.dart';
import 'package:restic_movil/core/utils/inputs/custom_text_field.dart';
import 'package:intl/intl.dart';

class CloseShiftView extends GetView<CloseShiftController> {
  const CloseShiftView({super.key});

  @override
  Widget build(BuildContext context) {
    return CustomScaffold(
      title: 'Cierre de Caja',
      showBackButton: true,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: ReactiveForm(
          formGroup: controller.form,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildInstructionText(),
              const SizedBox(height: 30),
              _buildDeclaredCashField(),
              const SizedBox(height: 20),
              _buildRemarksField(),
              const SizedBox(height: 40),
              _buildSubmitButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInstructionText() {
    return const Text(
      'Ingrese el dinero en efectivo declarado en caja para finalizar el turno.',
      style: TextStyle(fontSize: 16, color: Colors.black87),
    );
  }

  Widget _buildDeclaredCashField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Efectivo Declarado *',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        const SizedBox(height: 10),
        CustomReactiveTextField<String>(
          formControlName: 'declaredCashAmount',
          keyboardType: TextInputType.number,
          inputFormatters: [
            FilteringTextInputFormatter.digitsOnly,
            ThousandsSeparatorInputFormatter(),
          ],
          prefixText: '\$ ',
          hintText: '0',
          validationMessages: {
            ValidationMessage.required: (error) => 'Requerido',
            ValidationMessage.min: (error) => 'Debe ser mayor a 0',
          },
        ),
      ],
    );
  }

  Widget _buildRemarksField() {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Observaciones (Opcional)',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        SizedBox(height: 10),
        CustomReactiveTextField<String>(
          formControlName: 'remarks',
          maxLines: 3,
          hintText: 'Ingrese una observación si hay diferencias',
        ),
      ],
    );
  }

  Widget _buildSubmitButton() {
    return ReactiveFormConsumer(
      builder: (context, form, child) {
        return CustomSubmitButton(
          text: 'Cerrar Caja',
          onPressed: form.valid
              ? () async {
                  final result = await controller.submitCloseShift();
                  if (result != null) {
                    _showSuccessModal(result);
                  }
                }
              : null,
        );
      },
    );
  }

  void _showSuccessModal(Map<String, dynamic> response) {
    final currencyFormat = NumberFormat.currency(
      locale: 'es_CO',
      symbol: '\$',
      decimalDigits: 0,
    );

    final expected = response['expectedCashAmount'] ?? 0.0;
    final declared = response['declaredCashAmount'] ?? 0.0;
    final difference = response['difference'] ?? 0.0;

    final message =
        '''
Efectivo Esperado: ${currencyFormat.format(expected)}
Efectivo Declarado: ${currencyFormat.format(declared)}
Diferencia: ${currencyFormat.format(difference)}
''';

    Get.dialog(
      ModalInfo(
        title: 'Caja Cerrada Correctamente',
        message: message,
        onClose: () {
          Get.back();
          Get.back();
        },
      ),
      barrierDismissible: false,
    );
  }
}
