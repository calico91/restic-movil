import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:restic_movil/app/data/models/combo_group_model.dart';
import 'package:restic_movil/app/data/models/combo_option_model.dart';
import 'package:restic_movil/app/data/models/product_model.dart';
import 'package:restic_movil/app/modules/take_order/controllers/combo_selection_controller.dart';

class ComboSelectionDialog extends StatelessWidget {
  final ProductModel product;
  final Function(ProductModel, int, String, List<Map<String, String>>, double)
      onConfirm;

  const ComboSelectionDialog({
    super.key,
    required this.product,
    required this.onConfirm,
  });

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ComboSelectionController>(
      init: ComboSelectionController(product: product, onConfirm: onConfirm),
      tag: 'combo_${product.id}',
      builder: (controller) {
        return AlertDialog(
          title: Text(product.name ?? 'Arma tu Combo'),
          content: SingleChildScrollView(
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
                  decoration: const InputDecoration(
                    labelText: 'Comentarios adicionales',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 2,
                ),
                const SizedBox(height: 16),
                Align(
                  alignment: Alignment.centerRight,
                  child: Obx(() => Text(
                        'Total: \$${controller.totalPrice.toStringAsFixed(0)}',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.green,
                        ),
                      )),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
                onPressed: () => Get.back(), child: const Text('Cancelar')),
            Obx(() => ElevatedButton(
                  onPressed: controller.isValid ? controller.submit : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        controller.isValid ? Colors.blue[900] : Colors.grey,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Agregar'),
                )),
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
                icon: const Icon(Icons.remove, color: Colors.blue),
                onPressed: () => controller.updateQuantity(-1),
              ),
              Obx(() => Text(
                    '${controller.quantity.value}',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  )),
              IconButton(
                icon: const Icon(Icons.add, color: Colors.blue),
                onPressed: () => controller.updateQuantity(1),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildGroupSection(
      ComboGroupModel group, ComboSelectionController controller) {
    final options = group.options ?? [];
    options.sort(
      (a, b) => (a.displayOrder ?? 0).compareTo(b.displayOrder ?? 0),
    );

    return Obx(() {
      final currentCount = controller.getGroupTotalCount(group.id);
      final min = controller.getAdjustedLimit(group.minSelections ?? 0);
      final max = controller.getAdjustedLimit(group.maxSelections ?? 1);

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
