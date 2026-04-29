import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:reactive_forms/reactive_forms.dart';
import 'package:restic_movil/app/data/models/price_model.dart';
import 'package:restic_movil/app/data/models/product_model.dart';
import 'package:restic_movil/core/utils/inputs/custom_text_field.dart';

/// Diálogo para agregar un producto al pedido con cantidad y comentarios.
class AddProductDialog extends StatelessWidget {
  final ProductModel product;
  final PriceModel? price;
  final void Function(int quantity, String? comment) onConfirm;

  const AddProductDialog({
    super.key,
    required this.product,
    required this.onConfirm,
    this.price,
  });

  @override
  Widget build(BuildContext context) {
    final FormControl<int> quantityControl = FormControl<int>(value: 1);
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
          CustomReactiveTextField<int>(
            formControl: quantityControl,
            keyboardType: TextInputType.number,
            labelText: 'Cantidad',
          ),
          const SizedBox(height: 10),
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
          onPressed: () =>
              onConfirm(quantityControl.value ?? 1, commentControl.value),
          child: const Text('Agregar'),
        ),
      ],
    );
  }
}
