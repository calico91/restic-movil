import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:reactive_forms/reactive_forms.dart';
import 'package:restic_movil/app/modules/cash_register/controllers/close_shift/close_shift_controller.dart';
import 'package:restic_movil/core/utils/formatters/thousands_separator_input_formatter.dart';
import 'package:restic_movil/core/utils/widgets/custom_scaffold.dart';
import 'package:restic_movil/core/utils/modals/modal_info.dart';
import 'package:intl/intl.dart';
import 'package:restic_movil/app/routes/app_routes.dart';

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
        ReactiveTextField<String>(
          formControlName: 'declaredCashAmount',
          keyboardType: TextInputType.number,
          inputFormatters: [
            FilteringTextInputFormatter.digitsOnly,
            ThousandsSeparatorInputFormatter(),
          ],
          decoration: InputDecoration(
            prefixText: '\$ ',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
            filled: true,
            fillColor: Colors.grey[100],
            hintText: '0',
          ),
          validationMessages: {
            ValidationMessage.required: (error) => 'Requerido',
            ValidationMessage.min: (error) => 'Debe ser mayor a 0',
          },
        ),
      ],
    );
  }

  Widget _buildRemarksField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Observaciones (Opcional)',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        const SizedBox(height: 10),
        ReactiveTextField<String>(
          formControlName: 'remarks',
          maxLines: 3,
          decoration: InputDecoration(
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
            filled: true,
            fillColor: Colors.grey[100],
            hintText: 'Ingrese una observación si hay diferencias',
          ),
        ),
      ],
    );
  }

  Widget _buildSubmitButton() {
    return SizedBox(
      width: double.infinity,
      child: ReactiveFormConsumer(
        builder: (context, form, child) {
          return ElevatedButton(
            onPressed: form.valid
                ? () async {
                    final result = await controller.submitCloseShift();
                    if (result != null) {
                      _showSuccessModal(result);
                    }
                  }
                : null,
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              backgroundColor: Colors.blue[900],
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              elevation: 4,
            ),
            child: const Text(
              'Cerrar Caja',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          );
        },
      ),
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
          Get.back(); // Cierra el modal
          Get.offAllNamed(Routes.HOME); // Redirige al home y borra el stack
        },
      ),
      barrierDismissible: false,
    );
  }
}
