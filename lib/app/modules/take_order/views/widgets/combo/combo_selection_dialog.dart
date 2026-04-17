import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:restic_movil/app/data/models/combo_group_model.dart';
import 'package:restic_movil/app/data/models/combo_option_model.dart';
import 'package:restic_movil/app/data/models/price_model.dart';
import 'package:restic_movil/app/data/models/product_model.dart';
import 'package:restic_movil/app/modules/take_order/controllers/combo_selection_controller.dart';

class ComboSelectionDialog extends StatelessWidget {
  final ProductModel product;
  final PriceModel? price;
  final Function(ProductModel, PriceModel?, int, String, List<Map<String, String>>, double)
  onConfirm;

  const ComboSelectionDialog({
    super.key,
    required this.product,
    this.price,
    required this.onConfirm,
  });

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ComboSelectionController>(
      init: ComboSelectionController(product: product, price: price, onConfirm: onConfirm),
      tag: 'combo_${product.id}',
      builder: (controller) {
        return AlertDialog(
          backgroundColor: const Color(0xFFF5F6FA),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Text(
            product.name ?? 'Arma tu Combo',
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: Color(0xFF0D47A1), // Deep Blue del tema
            ),
          ),
          content: SizedBox(
            width: double.maxFinite,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (product.description != null)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 16.0),
                      child: Text(
                        product.description!,
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                    ),

                  // Selector de Cantidad Global
                  _buildQuantitySelector(controller),
                  const Divider(),

                  ...?product.comboGroups?.map(
                    (group) => _buildGroupSection(group, controller),
                  ),

                  const SizedBox(height: 16),
                  TextFormField(
                    controller: controller.commentController,
                    decoration: InputDecoration(
                      labelText: 'Comentarios adicionales',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    maxLines: 2,
                  ),
                  const SizedBox(height: 16),
                  Align(
                    alignment: Alignment.centerRight,
                    child: Obx(
                      () => Text(
                        'Total: \$${controller.totalPrice.toStringAsFixed(0)}',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF0D47A1),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          actions: [
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Get.back(),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.red[800],
                      side: BorderSide(color: Colors.red[800]!),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: const Text('Cancelar'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Obx(
                    () => ElevatedButton(
                      onPressed: controller.isValid ? controller.submit : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF0D47A1),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        disabledBackgroundColor: Colors.grey[300],
                      ),
                      child: const Text('Agregar'),
                    ),
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  Widget _buildQuantitySelector(ComboSelectionController controller) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text(
          'Cantidad de Combos:',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        Container(
          decoration: BoxDecoration(
            color: Colors.grey[100],
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            children: [
              IconButton(
                icon: const Icon(Icons.remove, color: Color(0xFF0D47A1)),
                onPressed: () => controller.updateQuantity(-1),
              ),
              Obx(
                () => Text(
                  '${controller.quantity.value}',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.add, color: Color(0xFF0D47A1)),
                onPressed: () => controller.updateQuantity(1),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildGroupSection(
    ComboGroupModel group,
    ComboSelectionController controller,
  ) {
    final options = group.options ?? [];
    options.sort(
      (a, b) => (a.displayOrder ?? 0).compareTo(b.displayOrder ?? 0),
    );

    return Obx(() {
      final currentCount = controller.getGroupTotalCount(group.id);
      final min = controller.getAdjustedLimit(group.minSelections ?? 0);
      // Validar con la cantidad seleccionada en el input, ignorando el json
      final max = controller.quantity.value;

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      group.name ?? '',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    if (group.required == true && currentCount < min)
                      const Text(' *', style: TextStyle(color: Colors.red)),
                  ],
                ),
                Text(
                  'Seleccionados: $currentCount / $max (Mínimo $min)',
                  style: TextStyle(
                    fontSize: 12,
                    color: currentCount < min ? Colors.red : Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          ...options.map(
            (option) =>
                _buildOptionRow(group, option, max, currentCount, controller),
          ),
          const Divider(),
        ],
      );
    });
  }

  Widget _buildOptionRow(
    ComboGroupModel group,
    ComboOptionModel option,
    int maxTotal,
    int currentTotal,
    ComboSelectionController controller,
  ) {
    final price = option.additionalPrice ?? 0;

    // Direct access to value with automatic update when parent rebuilds
    final count = controller.getOptionCount(group.id, option.id);
    final canIncrement = currentTotal < maxTotal;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(option.productName ?? ''),
                if (price > 0)
                  Text(
                    '+ \$${price.toStringAsFixed(0)}',
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                  ),
              ],
            ),
          ),
          Container(
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey[300]!),
            ),
            height: 36,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.remove, size: 16),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(minWidth: 32),
                  onPressed: count > 0
                      ? () => controller.decrementOption(group, option)
                      : null,
                ),
                Text(
                  '$count',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                IconButton(
                  icon: const Icon(Icons.add, size: 16),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(minWidth: 32),
                  onPressed: canIncrement
                      ? () => controller.incrementOption(group, option)
                      : null,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
