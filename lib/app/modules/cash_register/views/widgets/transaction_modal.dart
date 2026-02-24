import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:reactive_forms/reactive_forms.dart';
import 'package:restic_movil/app/data/models/order_model.dart';
import 'package:restic_movil/app/modules/cash_register/controllers/cash_register_controller.dart';
import 'package:restic_movil/app/data/models/create_transaction_request.dart';
import 'package:restic_movil/app/data/models/payment_detail_model.dart';
import 'package:restic_movil/core/utils/formatters/thousands_separator_input_formatter.dart';
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
      return double.tryParse(value.replaceAll('.', '')) ?? 0.0;
    }
    return 0.0;
  }

  @override
  Widget build(BuildContext context) {
    final form = controller.createTransactionForm(order);

    final currencyFormat = NumberFormat.currency(
      locale: 'es_CO',
      symbol: '\$',
      decimalDigits: 0,
    );

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
            _buildHeader(currencyFormat),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  _buildTransactionInfo(form, currencyFormat),
                  const SizedBox(height: 20),
                  _buildPaymentMethodsSection(form, currencyFormat),
                  const SizedBox(height: 20),
                  const Divider(),
                  _buildSummary(form, currencyFormat),
                ],
              ),
            ),
            _buildActions(form),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(NumberFormat currencyFormat) {
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

  Widget _buildTransactionInfo(FormGroup form, NumberFormat currencyFormat) {
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

          return ReactiveDropdownField<String>(
            formControlName: 'transactionType',
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              labelText: 'Tipo',
            ),
            items: types.map((type) {
              return DropdownMenuItem(
                value: type.code,
                child: Text(type.description ?? type.code ?? ''),
              );
            }).toList(),
            onChanged: (control) {},
          );
        }),

        // Show Original Transaction ID only for REFUND
        ReactiveValueListenableBuilder<String>(
          formControlName: 'transactionType',
          builder: (context, control, child) {
            if (control.value == 'REFUND') {
              return Padding(
                padding: const EdgeInsets.only(top: 10),
                child: ReactiveTextField(
                  formControlName: 'originalTransactionId',
                  decoration: const InputDecoration(
                    labelText: 'ID Transacción Original',
                    border: OutlineInputBorder(),
                    helperText: 'Requerido para devoluciones',
                  ),
                ),
              );
            }
            return const SizedBox.shrink();
          },
        ),

        const SizedBox(height: 15),
        const Text(
          'Propina (Opcional)',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
        ),
        const SizedBox(height: 5),
        ReactiveTextField<String>(
          formControlName: 'tipAmount',
          keyboardType: TextInputType.number,
          inputFormatters: [ThousandsSeparatorInputFormatter()],
          decoration: const InputDecoration(
            prefixText: '\$ ',
            border: OutlineInputBorder(),
          ),
        ),
      ],
    );
  }

  Widget _buildPaymentMethodsSection(
    FormGroup form,
    NumberFormat currencyFormat,
  ) {
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
                      value: currencyFormat.format(remaining),
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
                    return ReactiveDropdownField<String>(
                      formControl:
                          group.control('paymentMethod') as FormControl<String>,
                      isExpanded: true,
                      decoration: const InputDecoration(
                        labelText: 'Método',
                        border: OutlineInputBorder(),
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 8,
                        ),
                      ),
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
                  child: ReactiveTextField<String>(
                    formControl: group.control('amount') as FormControl<String>,
                    keyboardType: TextInputType.number,
                    inputFormatters: [ThousandsSeparatorInputFormatter()],
                    decoration: const InputDecoration(
                      labelText: 'Monto',
                      prefixText: '\$ ',
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 8,
                      ),
                    ),
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
                              child: ReactiveTextField(
                                formControl:
                                    group.control('cardLastFour')
                                        as FormControl<String>,
                                keyboardType: TextInputType.number,
                                maxLength: 4,
                                decoration: const InputDecoration(
                                  labelText: 'Últimos 4',
                                  border: OutlineInputBorder(),
                                  counterText: "",
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: ReactiveTextField(
                                formControl:
                                    group.control('cardBrand')
                                        as FormControl<String>,
                                decoration: const InputDecoration(
                                  labelText: 'Franquicia',
                                  hintText: 'Visa/Master',
                                  border: OutlineInputBorder(),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            Expanded(
                              child: ReactiveTextField(
                                formControl:
                                    group.control('authorizationCode')
                                        as FormControl<String>,
                                decoration: const InputDecoration(
                                  labelText: 'Cód. Autorización',
                                  border: OutlineInputBorder(),
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: ReactiveTextField(
                                formControl:
                                    group.control('referenceNumber')
                                        as FormControl<String>,
                                decoration: const InputDecoration(
                                  labelText: 'Referencia',
                                  border: OutlineInputBorder(),
                                ),
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

  Widget _buildSummary(FormGroup form, NumberFormat currencyFormat) {
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
            orderTotal; // If positive -> change, negative -> remaining

        return Column(
          children: [
            _summaryRow('Total Pedido:', orderTotal, currencyFormat),
            _summaryRow('Propina:', tip, currencyFormat),
            const Divider(),
            _summaryRow(
              'Total a Pagar:',
              orderTotal + tip,
              currencyFormat,
              isBold: true,
            ),
            const SizedBox(height: 10),
            _summaryRow(
              'Total Cubierto:',
              totalPaid,
              currencyFormat,
              color: Colors.blue,
            ),
            if (difference < 0)
              _summaryRow(
                'Faltante:',
                difference.abs(),
                currencyFormat,
                color: Colors.red,
              )
            else
              _summaryRow(
                'Cambio / Devolución:',
                difference,
                currencyFormat,
                color: Colors.green,
              ),
          ],
        );
      },
    );
  }

  Widget _summaryRow(
    String label,
    double value,
    NumberFormat fmt, {
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
            fmt.format(value),
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
          return SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: form.valid
                  ? () {
                      _submitTransaction(form);
                    }
                  : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                padding: const EdgeInsets.symmetric(vertical: 15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Text(
                'Completar Transacción',
                style: TextStyle(fontSize: 16, color: Colors.white),
              ),
            ),
          );
        },
      ),
    );
  }

  void _submitTransaction(FormGroup form) {
    final values = form.value;

    final tipAmount = _parseAmount(values['tipAmount']);
    final paymentsRaw = values['payments'] as List<dynamic>?;

    if (paymentsRaw == null || paymentsRaw.isEmpty) return;

    // Validate duplicate payment methods
    final paymentMethods =
        paymentsRaw.map((p) => p['paymentMethod'] as String).toList();
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
        const ErrorSnackbar(
          'El monto cubierto es menor al total a pagar.',
        ),
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
      orderId: order
          .id, // Assuming we need to link it, though prompt didn't specify orderId, usually it's needed or originalTransactionId
      totalAmount: order.total,
      tipAmount: tipAmount,
      transactionType: values['transactionType'] as String?,
      originalTransactionId: values['originalTransactionId'] as String?,
      paymentDetails: paymentDetails,
    );

    controller.createTransaction(request);
  }
}
