import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:reactive_forms/reactive_forms.dart';
import 'package:restic_movil/app/data/models/cash_withdrawal_payment_source.dart';
import 'package:restic_movil/app/data/models/cash_withdrawal_reason.dart';
import 'package:restic_movil/app/modules/cash_register/controllers/expenses/expenses_controller.dart';
import 'package:restic_movil/core/utils/widgets/custom_scaffold.dart';
import 'package:restic_movil/core/utils/buttons/custom_submit_button.dart';

class ExpensesView extends GetView<ExpensesController> {
  const ExpensesView({super.key});

  @override
  Widget build(BuildContext context) {
    return CustomScaffold(
      title: 'Egresos de Caja',
      showBackButton: true,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: ReactiveForm(
          formGroup: controller.form,
          child: Column(
            children: [
              ReactiveTextField(
                formControlName: 'amount',
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                decoration: InputDecoration(
                  labelText: 'Monto *',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                validationMessages: {
                  ValidationMessage.required: (error) =>
                      'El monto es obligatorio',
                  ValidationMessage.number: (error) =>
                      'Debe ingresar un número válido',
                },
              ),
              const SizedBox(height: 16),
              ReactiveTextField(
                formControlName: 'concept',
                decoration: InputDecoration(
                  labelText: 'Concepto *',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                validationMessages: {
                  ValidationMessage.required: (error) =>
                      'El concepto es obligatorio',
                },
              ),
              const SizedBox(height: 16),
              ReactiveTextField(
                formControlName: 'voucherReference',
                decoration: InputDecoration(
                  labelText: 'Referencia Comprobante (Opcional)',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Obx(
                () => ReactiveDropdownField<CashWithdrawalReason>(
                  formControlName: 'reason',
                  decoration: InputDecoration(
                    labelText: 'Motivo *',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  items: controller.reasons
                      .map((e) => DropdownMenuItem(
                            value: e,
                            child: Text(e.description),
                          ))
                      .toList(),
                  validationMessages: {
                    ValidationMessage.required: (error) =>
                        'Seleccione un motivo',
                  },
                ),
              ),
              const SizedBox(height: 16),
              Obx(
                () => ReactiveDropdownField<CashWithdrawalPaymentSource>(
                  formControlName: 'paymentSource',
                  decoration: InputDecoration(
                    labelText: 'Medio de Pago *',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  items: controller.paymentSources
                      .map((e) => DropdownMenuItem(
                            value: e,
                            child: Text(e.description),
                          ))
                      .toList(),
                  validationMessages: {
                    ValidationMessage.required: (error) =>
                        'Seleccione un medio de pago',
                  },
                ),
              ),
              const SizedBox(height: 16),
              ReactiveValueListenableBuilder<CashWithdrawalPaymentSource>(
                formControlName: 'paymentSource',
                builder: (context, control, child) {
                  final source = control.value;
                  if (source?.name == 'BANK_ACCOUNT') {
                    return Column(
                      children: [
                        ReactiveTextField(
                          formControlName: 'bankAccountName',
                          decoration: InputDecoration(
                            labelText: 'Nombre Cuenta Bancaria *',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          validationMessages: {
                            ValidationMessage.required: (error) =>
                                'El nombre de la cuenta es obligatorio',
                          },
                        ),
                        const SizedBox(height: 16),
                        ReactiveTextField(
                          formControlName: 'bankAccountReference',
                          decoration: InputDecoration(
                            labelText: 'Referencia Bancaria',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                      ],
                    );
                  }
                  return const SizedBox.shrink();
                },
              ),
              const SizedBox(height: 20),
              ReactiveFormConsumer(
                builder: (context, form, child) {
                  return CustomSubmitButton(
                    text: 'Registrar Egreso',
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
