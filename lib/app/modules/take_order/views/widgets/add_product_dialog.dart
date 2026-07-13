import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:reactive_forms/reactive_forms.dart';
import 'package:restic_movil/app/data/models/price_model.dart';
import 'package:restic_movil/app/data/models/product_model.dart';
import 'package:restic_movil/core/utils/inputs/custom_text_field.dart';

/// Diálogo para agregar un comentario a productos ya agregados al pedido.
class AddProductDialog extends StatelessWidget {
  final ProductModel product;
  final PriceModel? price;
  final int currentQuantity;
  final void Function(String? comment) onConfirm;

  const AddProductDialog({
    super.key,
    required this.product,
    required this.price,
    required this.currentQuantity,
    required this.onConfirm,
  });

  @override
  Widget build(BuildContext context) {
    final FormControl<String> commentControl = FormControl<String>(value: '');

    return AlertDialog(
      title: Text(
        product.productType == 'VARIABLE' && price?.sizeLabel != null
            ? 'Producto: ${product.name} - ${price!.sizeLabel}'
            : 'Producto: ${product.name}',
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.blue[50],
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.blue[100]!),
            ),
            child: Row(
              children: [
                Icon(Icons.info_outline, color: Colors.blue[700], size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Se aplicará el comentario a $currentQuantity producto(s) ya agregado(s).',
                    style: TextStyle(
                      color: Colors.blue[900],
                      fontSize: 13,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          CustomReactiveTextField<String>(
            formControl: commentControl,
            labelText: 'Comentarios',
            maxLines: 3,
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Get.back(),
          child: const Text('Cancelar'),
        ),
        ElevatedButton(
          onPressed: () => onConfirm(commentControl.value),
          child: const Text('Aplicar'),
        ),
      ],
    );
  }
}
