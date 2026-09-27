import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:reactive_forms/reactive_forms.dart';
import 'package:restic_movil/app/data/models/order_model.dart';
import 'package:restic_movil/core/utils/formatters/currency_formatter.dart';
import 'package:restic_movil/core/utils/inputs/custom_text_field.dart';
import 'package:restic_movil/core/utils/modals/custom_form_dialog.dart';
import 'package:restic_movil/core/utils/modals/modal_error.dart';

class CancelOrderDialog extends StatefulWidget {
  final OrderModel order;
  final void Function(String reason) onSubmit;

  const CancelOrderDialog({
    super.key,
    required this.order,
    required this.onSubmit,
  });

  @override
  State<CancelOrderDialog> createState() => _CancelOrderDialogState();
}

class _CancelOrderDialogState extends State<CancelOrderDialog> {
  late final FormGroup _form;

  @override
  void initState() {
    super.initState();
    _form = FormGroup({
      'reason': FormControl<String>(
        validators: [
          Validators.required,
          Validators.minLength(5),
          Validators.maxLength(500),
        ],
      ),
    });
  }

  OrderModel get order => widget.order;

  @override
  Widget build(BuildContext context) {
    return CustomFormDialog(
      title: 'Anular orden',
      autoClose: false,
      saveText: 'Anular orden',
      formGroup: _form,
      onSave: () {
        final raw = (_form.control('reason').value as String?)?.trim() ?? '';
        if (raw.length < 5) {
          Get.dialog(const ModalError(
              message: 'El motivo debe tener al menos 5 caracteres.'));
          return;
        }
        widget.onSubmit(raw);
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildWarning(),
          const SizedBox(height: 16),
          _buildOrderInfo(),
          const SizedBox(height: 16),
          CustomReactiveTextField<String>(
            formControlName: 'reason',
            labelText: 'Motivo de la anulación',
            hintText: 'Ej: Cliente desiste del pedido',
            maxLines: 3,
            maxLength: 500,
            validationMessages: {
              ValidationMessage.required: (_) => 'El motivo es obligatorio',
              ValidationMessage.minLength: (_) =>
                  'El motivo debe tener al menos 5 caracteres',
              ValidationMessage.maxLength: (_) =>
                  'El motivo no puede superar los 500 caracteres',
            },
          ),
        ],
      ),
    );
  }

  Widget _buildWarning() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.red.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.red.withValues(alpha: 0.3)),
      ),
      child: const Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.warning_amber_rounded, color: Colors.red, size: 20),
          SizedBox(width: 8),
          Expanded(
            child: Text(
              'La orden pasará a Anulada y no se podrá reactivar. No afecta caja ni inventario porque aún no ha sido cobrada. Si fue tomada por error, vuelve a crear la orden.',
              style: TextStyle(fontSize: 13, color: Colors.black87),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderInfo() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _infoRow('Orden', '#${order.orderNumber ?? '-'}'),
          const SizedBox(height: 4),
          _infoRow('Total', CurrencyFormatter.toCurrency(order.total ?? 0)),
          Builder(builder: (_) {
            final customerName = order.customer?.fullName;
            if (customerName == null || customerName.isEmpty) {
              return const SizedBox.shrink();
            }
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 4),
                _infoRow('Cliente', customerName),
              ],
            );
          }),
        ],
      ),
    );
  }

  Widget _infoRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(color: Colors.black54)),
        Text(
          value,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
      ],
    );
  }
}
