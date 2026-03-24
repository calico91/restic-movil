import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:restic_movil/core/utils/formatters/thousands_separator_input_formatter.dart';
import 'package:reactive_forms/reactive_forms.dart';
import 'package:restic_movil/app/data/models/create_transaction_request.dart';
import 'package:restic_movil/app/data/models/order_model.dart';
import 'package:restic_movil/app/data/models/payment_detail_model.dart';
import 'package:restic_movil/app/modules/cash_register/controllers/cash_register_controller.dart';
import 'package:restic_movil/core/utils/formatters/currency_formatter.dart';

import 'package:restic_movil/core/utils/inputs/custom_text_field.dart';
import 'package:restic_movil/core/utils/inputs/custom_dropdown_field.dart';
import 'package:restic_movil/core/utils/buttons/custom_submit_button.dart';
import 'package:restic_movil/core/utils/snackbars/error_snackbar.dart';

class TransactionModal extends StatelessWidget {
  final OrderModel order;
  final CashRegisterController controller = Get.find();

  TransactionModal({super.key, required this.order});

  double _parseAmount(dynamic value) {
    if (value == null) return 0.0;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) {
      if (value.isEmpty) return 0.0;
      final clean = value.replaceAll(RegExp(r'[^0-9]'), '');
      if (clean.isEmpty) return 0.0;
      return double.tryParse(clean) ?? 0.0;
    }
    return 0.0;
  }

  @override
  Widget build(BuildContext context) {
    final form = controller.createTransactionForm(order);

    return Container(
      height: Get.height * 0.85,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: ReactiveForm(
        formGroup: form,
        child: Column(
          children: [
            _buildHeader(),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  _buildTransactionInfo(form),
                  const SizedBox(height: 20),
                  _buildPaymentMethodsSection(form),
                  const SizedBox(height: 20),
                  const Divider(),
                  _buildSummary(form),
                ],
              ),
            ),
            _buildActions(form),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue[900],
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            'Registrar Pago',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          IconButton(
            icon: const Icon(Icons.close, color: Colors.white),
            onPressed: () => Get.back(),
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionInfo(FormGroup form) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Tipo de Transacción',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        const SizedBox(height: 10),
        Obx(() {
          final types = controller.transactionTypes;
          if (types.isEmpty) return const SizedBox.shrink();

          return CustomReactiveDropdownField<String>(
            formControlName: 'transactionType',
            labelText: 'Tipo',
            items: types.map((type) {
              return DropdownMenuItem(
                value: type.code,
                child: Text(type.description ?? type.code ?? ''),
              );
            }).toList(),
          );
        }),

        // Show Original Transaction ID only for REFUND
        ReactiveValueListenableBuilder<String>(
          formControlName: 'transactionType',
          builder: (context, control, child) {
            if (control.value == 'REFUND') {
              return const Padding(
                padding: EdgeInsets.only(top: 10),
                child: CustomReactiveTextField(
                  formControlName: 'originalTransactionId',
                  labelText: 'ID Transacción Original',
                  helperText: 'Requerido para devoluciones',
                ),
              );
            }
            return const SizedBox.shrink();
          },
        ),

        const SizedBox(height: 15),
        const Text(
          'Configuración de Pago y Propina',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            const Expanded(
              flex: 1,
              child: CustomReactiveTextField(
                formControlName: 'tipPercentage',
                keyboardType: TextInputType.number,
                labelText: '% Propina',
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              flex: 2,
              child: CustomReactiveTextField(
                formControlName: 'tipAmount',
                keyboardType: TextInputType.number,
                inputFormatters: [ThousandsSeparatorInputFormatter()],
                labelText: 'Monto Propina',
                prefixText: '\$ ',
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        CustomReactiveTextField(
          formControlName: 'totalToPay',
          keyboardType: TextInputType.number,
          inputFormatters: [ThousandsSeparatorInputFormatter()],
          labelText: 'Total a Pagar',
          prefixText: '\$ ',
        ),
      ],
    );
  }

  Widget _buildPaymentMethodsSection(FormGroup form) {
    // Access the FormArray called 'payments'
    final paymentsArray =
        form.control('payments') as FormArray<Map<String, dynamic>>;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Métodos de Pago',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            TextButton.icon(
              icon: const Icon(Icons.add),
              label: const Text('Agregar'),
              onPressed: () {
                // Determine remaining amount
                final currentTotal =
                    paymentsArray.value?.fold<double>(
                      0.0,
                      (sum, item) => sum + _parseAmount(item?['amount']),
                    ) ??
                    0.0;

                final orderTotal = order.total ?? 0.0;
                final remaining = (orderTotal - currentTotal).clamp(
                  0.0,
                  orderTotal,
                );

                paymentsArray.add(
                  FormGroup({
                    'paymentMethod': FormControl<String>(
                      value: 'CASH',
                      validators: [Validators.required],
                    ),
                    'amount': FormControl<String>(
                      value: CurrencyFormatter.toCurrency(
                        remaining,
                      ).replaceAll('\$', '').trim(),
                      validators: [Validators.required],
                    ),
                    'cardLastFour': FormControl<String>(),
                    'cardBrand': FormControl<String>(),
                    'authorizationCode': FormControl<String>(),
                    'referenceNumber': FormControl<String>(),
                  }),
                );
              },
            ),
          ],
        ),

        // Reactive rebuild when array changes
        ReactiveFormArray<Map<String, dynamic>>(
          formArrayName: 'payments',
          builder: (context, formArray, child) {
            return Column(
              children: List.generate(formArray.controls.length, (index) {
                final group = formArray.controls[index] as FormGroup;
                return _buildPaymentItem(
                  group,
                  index,
                  formArray,
                ); // Pass index and array to allow removal
              }),
            );
          },
        ),
      ],
    );
  }

  Widget _buildPaymentItem(FormGroup group, int index, FormArray formArray) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  flex: 2,
                  child: Obx(() {
                    final methods = controller.paymentMethods;
                    return CustomReactiveDropdownField<String>(
                      formControl:
                          group.control('paymentMethod') as FormControl<String>,
                      labelText: 'Método',
                      items: methods
                          .map(
                            (m) => DropdownMenuItem(
                              value: m.code,
                              child: Text(
                                m.description ?? m.code ?? 'Unknown',
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          )
                          .toList(),
                    );
                  }),
                ),
                const SizedBox(width: 10),
                Expanded(
                  flex: 2,
                  child: CustomReactiveTextField<String>(
                    formControl: group.control('amount') as FormControl<String>,
                    keyboardType: TextInputType.number,
                    inputFormatters: [ThousandsSeparatorInputFormatter()],
                    labelText: 'Monto',
                    prefixText: '\$ ',
                  ),
                ),
                if (formArray.controls.length > 1)
                  IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () {
                      formArray.removeAt(index);
                    },
                  ),
              ],
            ),

            // Card details if CREDIT_CARD or DEBIT_CARD
            ReactiveValueListenableBuilder<String>(
              formControl:
                  group.control('paymentMethod') as FormControl<String>,
              builder: (context, control, child) {
                final method = control.value;
                if (method == 'CREDIT_CARD' || method == 'DEBIT_CARD') {
                  return Padding(
                    padding: const EdgeInsets.only(top: 10),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: CustomReactiveTextField(
                                formControl:
                                    group.control('cardLastFour')
                                        as FormControl<String>,
                                keyboardType: TextInputType.number,
                                maxLength: 4,
                                labelText: 'Últimos 4',
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: CustomReactiveTextField(
                                formControl:
                                    group.control('cardBrand')
                                        as FormControl<String>,
                                labelText: 'Franquicia',
                                hintText: 'Visa/Master',
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            Expanded(
                              child: CustomReactiveTextField(
                                formControl:
                                    group.control('authorizationCode')
                                        as FormControl<String>,
                                labelText: 'Cód. Autorización',
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: CustomReactiveTextField(
                                formControl:
                                    group.control('referenceNumber')
                                        as FormControl<String>,
                                labelText: 'Referencia',
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                }
                return const SizedBox.shrink();
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummary(FormGroup form) {
    return ReactiveFormConsumer(
      builder: (context, form, child) {
        final orderTotal = order.total ?? 0.0;
        final tip = _parseAmount(form.control('tipAmount').value);

        final payments = (form.control('payments') as FormArray).value;
        final totalPaid =
            payments?.fold<double>(
              0.0,
              (sum, item) => sum + _parseAmount(item?['amount']),
            ) ??
            0.0;

        final difference =
            totalPaid -
            (orderTotal + tip); // If positive -> change, negative -> remaining

        return Column(
          children: [
            _summaryRow('Total Pedido:', orderTotal),
            _summaryRow('Propina:', tip),
            const Divider(),
            _summaryRow('Total a Pagar:', orderTotal + tip, isBold: true),
            const SizedBox(height: 10),
            _summaryRow('Total Cubierto:', totalPaid, color: Colors.blue),
            if (difference < -0.01)
              _summaryRow('Faltante:', difference.abs(), color: Colors.red)
            else
              _summaryRow(
                'Cambio / Devolución:',
                difference,
                color: Colors.green,
              ),
          ],
        );
      },
    );
  }

  Widget _summaryRow(
    String label,
    double value, {
    bool isBold = false,
    Color? color,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
              fontSize: 16,
            ),
          ),
          Text(
            CurrencyFormatter.toCurrency(value),
            style: TextStyle(
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
              fontSize: 16,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActions(FormGroup form) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: ReactiveFormConsumer(
        builder: (context, form, child) {
          return CustomSubmitButton(
            text: 'Completar Transacción',
            onPressed: form.valid
                ? () {
                    _submitTransaction(form);
                  }
                : null,
            backgroundColor: Colors.green,
          );
        },
      ),
    );
  }

  void _submitTransaction(FormGroup form) {
    final values = form.value;

    final tipAmount = _parseAmount(values['tipAmount']);
    final totalToPayInput = _parseAmount(values['totalToPay']);
    final paymentsRaw = values['payments'] as List<dynamic>?;

    if (paymentsRaw == null || paymentsRaw.isEmpty) return;

    // Validar que el total a pagar no sea inferior al total del pedido.
    final orderTotal = order.total ?? 0.0;
    if (totalToPayInput < orderTotal) {
      Get.showSnackbar(
        const ErrorSnackbar('El total a pagar no puede ser menor al total del pedido'),
      );
      return;
    }

    // Validate duplicate payment methods
    final paymentMethods = paymentsRaw
        .map((p) => p['paymentMethod'] as String)
        .toList();
    final uniqueMethods = paymentMethods.toSet();
    if (uniqueMethods.length != paymentMethods.length) {
      Get.showSnackbar(
        const ErrorSnackbar('No se pueden repetir métodos de pago'),
      );
      return;
    }

    // Validate total covered
    final totalPaid = paymentsRaw.fold<double>(
      0.0,
      (sum, p) => sum + _parseAmount(p['amount']),
    );
    final totalToPay = (order.total ?? 0.0) + tipAmount;

    // Allow a small epsilon for floating point comparison if necessary, but >= logic usually fine
    if (totalPaid < totalToPay) {
      Get.showSnackbar(
        const ErrorSnackbar('El monto cubierto es menor al total a pagar.'),
      );
      return;
    }

    final paymentDetails = paymentsRaw.map((p) {
      final map = p as Map<String, dynamic>;

      final method = map['paymentMethod'];
      final isCard = method == 'CREDIT_CARD' || method == 'DEBIT_CARD';

      return PaymentDetailModel(
        amount: _parseAmount(map['amount']),
        paymentMethod: map['paymentMethod'],
        currency: 'COP',
        cardLastFour: isCard ? map['cardLastFour'] : null,
        cardBrand: isCard ? map['cardBrand'] : null,
        authorizationCode: isCard ? map['authorizationCode'] : null,
        referenceNumber: isCard ? map['referenceNumber'] : null,
      );
    }).toList();

    // Create Request
    final request = CreateTransactionRequest(
      orderId: order.id,
      totalAmount: order.total,
      tipAmount: tipAmount,
      transactionType: values['transactionType'] as String?,
      originalTransactionId: values['originalTransactionId'] as String?,
      paymentDetails: paymentDetails,
    );

    controller.createTransaction(request);
  }
}
