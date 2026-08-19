import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:reactive_forms/reactive_forms.dart';
import 'package:restic_movil/app/data/models/order_model.dart';
import 'package:restic_movil/app/modules/cash_register/controllers/cash_register_controller.dart';

import 'package:restic_movil/core/utils/inputs/custom_text_field.dart';
import 'package:restic_movil/core/utils/inputs/custom_dropdown_field.dart';
import 'package:restic_movil/core/utils/buttons/custom_submit_button.dart';
import 'package:restic_movil/core/utils/modals/modal_error.dart';

class ChangePaymentMethodModal extends StatefulWidget {
  final OrderModel order;

  const ChangePaymentMethodModal({super.key, required this.order});

  @override
  State<ChangePaymentMethodModal> createState() =>
      _ChangePaymentMethodModalState();
}

class _ChangePaymentMethodModalState extends State<ChangePaymentMethodModal> {
  final CashRegisterController controller = Get.find();
  late final FormGroup _form;
  late final double _lockedTotal;

  @override
  void initState() {
    super.initState();
    _lockedTotal = widget.order.total ?? 0.0;
    _form = _buildForm();
  }

  OrderModel get order => widget.order;

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

  FormGroup _buildForm() {
    final formatter = NumberFormat.decimalPattern('es_CO');
    final defaultMethod = controller.paymentMethods.isNotEmpty
        ? controller.paymentMethods.first.method
        : 'CASH';

    return FormGroup({
      'payments': FormArray<Map<String, dynamic>>([
        FormGroup({
          'paymentMethod': FormControl<String>(
            value: defaultMethod,
            validators: [Validators.required],
          ),
          'amount': FormControl<String>(
            value: formatter.format(_lockedTotal),
            validators: [Validators.required],
          ),
          'cardLastFour': FormControl<String>(),
          'cardBrand': FormControl<String>(),
          'authorizationCode': FormControl<String>(),
          'referenceNumber': FormControl<String>(),
        }),
      ]),
      'reason': FormControl<String>(),
    });
  }

  @override
  Widget build(BuildContext context) {
    final form = _form;

    return Container(
      height: Get.height * 0.75,
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
                  _buildOrderInfo(),
                  const SizedBox(height: 16),
                  _buildLockedAmounts(),
                  const SizedBox(height: 16),
                  _buildPaymentMethodsSection(form),
                  const SizedBox(height: 16),
                  const Divider(),
                  _buildSummary(form),
                  const SizedBox(height: 12),
                  _buildReasonField(),
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
        color: Colors.orange[700],
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            'Cambiar método de pago',
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

  Widget _buildOrderInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Pedido #${order.orderNumber ?? 'N/A'}',
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        const SizedBox(height: 4),
        Text(
          'Cliente: ${order.customer?.name ?? 'N/A'} ${order.customer?.lastName ?? ''}',
          style: const TextStyle(color: Colors.black54),
        ),
      ],
    );
  }

  Widget _buildLockedAmounts() {
    final formatter = NumberFormat.decimalPattern('es_CO');
    return Card(
      color: Colors.grey[100],
      elevation: 0,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            const Icon(Icons.lock_outline, size: 18, color: Colors.black54),
            const SizedBox(width: 8),
            const Text(
              'Total bloqueado: ',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
            Text(
              '\$ ${formatter.format(_lockedTotal)}',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentMethodsSection(FormGroup form) {
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
                if (controller.paymentMethods.length <= 1) {
                  Get.dialog(const ModalError(
                      message:
                          'Solo tienes un método de pago configurado. Agrega más métodos en la sección de Métodos de Pago.'));
                  return;
                }
                final currentTotal = paymentsArray.value?.fold<double>(
                      0.0,
                      (sum, item) => sum + _parseAmount(item?['amount']),
                    ) ??
                    0.0;
                final remaining = (_lockedTotal - currentTotal).clamp(
                  0.0,
                  _lockedTotal,
                );
                final usedMethods = paymentsArray.value
                        ?.map((item) => item?['paymentMethod'] as String?)
                        .whereType<String>()
                        .toSet() ??
                    <String>{};
                final nextMethod = controller.paymentMethods.firstWhere(
                  (m) => !usedMethods.contains(m.method),
                  orElse: () => controller.paymentMethods[1],
                );
                final formatter = NumberFormat.decimalPattern('es_CO');
                paymentsArray.add(FormGroup({
                  'paymentMethod': FormControl<String>(
                    value: nextMethod.method,
                    validators: [Validators.required],
                  ),
                  'amount': FormControl<String>(
                    value: formatter.format(remaining),
                    validators: [Validators.required],
                  ),
                  'cardLastFour': FormControl<String>(),
                  'cardBrand': FormControl<String>(),
                  'authorizationCode': FormControl<String>(),
                  'referenceNumber': FormControl<String>(),
                }));
              },
            ),
          ],
        ),
        ReactiveFormArray<Map<String, dynamic>>(
          formArrayName: 'payments',
          builder: (context, formArray, child) {
            return Column(
              children: List.generate(formArray.controls.length, (index) {
                final group = formArray.controls[index] as FormGroup;
                return _buildPaymentItem(group, index);
              }),
            );
          },
        ),
      ],
    );
  }

  Widget _buildPaymentItem(FormGroup group, int index) {
    final paymentsArray = _form.control('payments') as FormArray;
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6),
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(8),
      ),
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
                            value: m.method,
                            child: Text(
                              m.displayName ?? m.method ?? 'Unknown',
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        )
                        .toList(),
                  );
                }),
              ),
              const SizedBox(width: 8),
              Expanded(
                flex: 2,
                child: CustomReactiveTextField<String>(
                  formControl: group.control('amount') as FormControl<String>,
                  labelText: 'Monto',
                  keyboardType: TextInputType.number,
                ),
              ),
              if (paymentsArray.controls.length > 1)
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () => paymentsArray.removeAt(index),
                ),
            ],
          ),
          const SizedBox(height: 8),
          ReactiveValueListenableBuilder<String>(
            formControl: group.control('paymentMethod') as FormControl<String>,
            builder: (context, value, child) {
              final isCard = value.value == 'CREDIT_CARD' ||
                  value.value == 'DEBIT_CARD';
              if (!isCard) return const SizedBox.shrink();
              return Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: CustomReactiveTextField<String>(
                          formControl: group.control('cardLastFour') as FormControl<String>,
                          labelText: 'Últimos 4',
                          keyboardType: TextInputType.number,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: CustomReactiveTextField<String>(
                          formControl: group.control('cardBrand') as FormControl<String>,
                          labelText: 'Marca',
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: CustomReactiveTextField<String>(
                          formControl: group.control('authorizationCode') as FormControl<String>,
                          labelText: 'Cód. autorización',
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: CustomReactiveTextField<String>(
                          formControl: group.control('referenceNumber') as FormControl<String>,
                          labelText: 'Referencia',
                        ),
                      ),
                    ],
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSummary(FormGroup form) {
    final formatter = NumberFormat.decimalPattern('es_CO');
    return StreamBuilder<Map<String, dynamic>?>(
      stream: form.valueChanges,
      builder: (context, snapshot) {
        final payments = (form.control('payments') as FormArray).value ?? [];
        final totalPaid = payments.fold<double>(
            0.0, (sum, item) => sum + _parseAmount(item?['amount']));
        final diff = totalPaid - _lockedTotal;
        final diffLabel = diff > 0
            ? 'Vuelto: \$ ${formatter.format(diff)}'
            : (diff < 0
                ? 'Faltante: \$ ${formatter.format(-diff)}'
                : 'Cuadra exacto');
        final color = diff > 0
            ? Colors.green[700]
            : (diff < 0 ? Colors.red : Colors.grey[600]);
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Total pagado:',
                    style: TextStyle(fontWeight: FontWeight.w600)),
                Text('\$ ${formatter.format(totalPaid)}'),
              ],
            ),
            const SizedBox(height: 4),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(diff > 0 ? diffLabel : diffLabel,
                    style: TextStyle(color: color, fontWeight: FontWeight.bold)),
              ],
            ),
          ],
        );
      },
    );
  }

  Widget _buildReasonField() {
    return const CustomReactiveTextField(
      formControlName: 'reason',
      labelText: 'Motivo del cambio (opcional)',
      maxLines: 2,
    );
  }

  Widget _buildActions(FormGroup form) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: ReactiveFormConsumer(
        builder: (context, formConsume, child) {
          return CustomSubmitButton(
            text: 'Guardar cambios',
            onPressed: formConsume.valid ? () => _submit(formConsume) : null,
            backgroundColor: Colors.orange[700],
          );
        },
      ),
    );
  }

  void _submit(FormGroup form) {
    final paymentsArray = form.control('payments') as FormArray;
    final paymentsRaw = paymentsArray.value ?? [];
    if (paymentsRaw.isEmpty) {
      Get.dialog(const ModalError(message: 'Debe existir al menos un método.'));
      return;
    }

    final totalPaid = paymentsRaw.fold<double>(
        0.0, (sum, item) => sum + _parseAmount(item?['amount']));

    if (totalPaid < _lockedTotal) {
      Get.dialog(const ModalError(
          message: 'El total de los pagos es menor al total a cobrar.'));
      return;
    }

    final usedMethods = paymentsRaw
        .map((item) => item?['paymentMethod'] as String?)
        .whereType<String>()
        .toSet();
    if (usedMethods.length != paymentsRaw.length) {
      Get.dialog(const ModalError(
          message: 'No repita el mismo método de pago.'));
      return;
    }

    final paymentDetailsJson = paymentsRaw.map((item) {
      final map = item as Map<String, dynamic>;
      final method = map['paymentMethod'] as String?;
      final isCard = method == 'CREDIT_CARD' || method == 'DEBIT_CARD';
      return {
        'paymentMethod': method,
        'amount': _parseAmount(map['amount']),
        'currency': 'COP',
        'cardLastFour': isCard ? (map['cardLastFour'] as String?) : null,
        'cardBrand': isCard ? (map['cardBrand'] as String?) : null,
        'authorizationCode':
            isCard ? (map['authorizationCode'] as String?) : null,
        'referenceNumber': isCard ? (map['referenceNumber'] as String?) : null,
      };
    }).toList();

    final reason = (form.control('reason').value as String?)?.trim();

    controller.submitChangePaymentMethod(
      transactionId: order.transactionId!,
      paymentDetails: paymentDetailsJson,
      reason: (reason != null && reason.isNotEmpty) ? reason : null,
    );
  }
}