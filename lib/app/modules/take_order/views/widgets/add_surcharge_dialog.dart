import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:restic_movil/core/utils/formatters/thousands_separator_input_formatter.dart';

/// Diálogo para agregar un cargo adicional al pedido.
class AddSurchargeDialog extends StatelessWidget {
  final void Function(String description, double amount) onConfirm;

  const AddSurchargeDialog({super.key, required this.onConfirm});

  @override
  Widget build(BuildContext context) {
    final TextEditingController descriptionController = TextEditingController();
    final TextEditingController amountController = TextEditingController();

    return AlertDialog(
      title: const Text('Agregar Cargo Adicional'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: descriptionController,
            decoration: const InputDecoration(
              labelText: 'Descripción (ej. Domicilio, Empaque)',
              border: OutlineInputBorder(),
            ),
            textCapitalization: TextCapitalization.sentences,
          ),
          const SizedBox(height: 16),
          TextField(
            controller: amountController,
            decoration: const InputDecoration(
              labelText: 'Monto',
              border: OutlineInputBorder(),
              prefixText: '\$ ',
            ),
            keyboardType: TextInputType.number,
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
              ThousandsSeparatorInputFormatter(),
            ],
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Get.back(),
          child: const Text('Cancelar'),
        ),
        ElevatedButton(
          onPressed: () {
            final String description = descriptionController.text.trim();
            final String amountStr = amountController.text.trim();
            if (description.isNotEmpty && amountStr.isNotEmpty) {
              final double? amount = double.tryParse(
                amountStr.replaceAll('.', '').replaceAll(',', ''),
              );
              if (amount != null && amount > 0) {
                onConfirm(description, amount);
                Get.back();
              } else {
                Get.snackbar(
                  'Error',
                  'Ingrese un monto válido mayor a 0',
                  snackPosition: SnackPosition.BOTTOM,
                  backgroundColor: Colors.red[100],
                  colorText: Colors.red[900],
                );
              }
            } else {
              Get.snackbar(
                'Error',
                'Complete ambos campos',
                snackPosition: SnackPosition.BOTTOM,
                backgroundColor: Colors.red[100],
                colorText: Colors.red[900],
              );
            }
          },
          child: const Text('Agregar'),
        ),
      ],
    );
  }
}
