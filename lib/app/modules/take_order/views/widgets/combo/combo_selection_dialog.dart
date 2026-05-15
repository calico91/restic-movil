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
              color: Color(0xFF0D47A1),
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

                  // Navegador de unidades por combo
                  _buildUnitNavigator(controller),
                  const Divider(),

                  // Grupos de opciones para la unidad activa
                  Obx(
                    () => Column(
                      children: [
                        ...?product.comboGroups?.map(
                          (group) => _buildGroupSection(
                            group,
                            controller,
                            controller.currentUnit.value,
                          ),
                        ),
                      ],
                    ),
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

  /* navegador de unidades: chips numerados + botones para agregar y quitar unidades */
  Widget _buildUnitNavigator(ComboSelectionController controller) {
    return Obx(() {
      final int total = controller.unitSelections.length;
      final int active = controller.currentUnit.value;

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Combos a armar:',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                // Chip por cada unidad
                ...List.generate(total, (i) {
                  final bool isActive = i == active;
                  final bool isUnitValid = controller.isValidForUnit(i);
                  return GestureDetector(
                    onTap: () => controller.currentUnit.value = i,
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      margin: const EdgeInsets.only(right: 8),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: isActive
                            ? const Color(0xFF0D47A1)
                            : Colors.grey[200],
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: (!isUnitValid && !isActive)
                              ? Colors.red
                              : Colors.transparent,
                          width: 1.5,
                        ),
                      ),
                      child: Text(
                        '${i + 1}',
                        style: TextStyle(
                          color: isActive ? Colors.white : Colors.black87,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  );
                }),

                // Botón agregar unidad
                IconButton(
                  icon: const Icon(
                    Icons.add_circle,
                    color: Color(0xFF0D47A1),
                  ),
                  tooltip: 'Agregar combo',
                  onPressed: controller.addUnit,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),

                // Botón quitar última unidad (solo si hay más de una)
                if (total > 1) ...[
                  const SizedBox(width: 4),
                  IconButton(
                    icon: Icon(Icons.remove_circle, color: Colors.red[700]),
                    tooltip: 'Quitar último combo',
                    onPressed: controller.removeUnit,
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
              ],
            ),
          ),
        ],
      );
    });
  }

  /* grupos de opciones de una unidad específica */
  Widget _buildGroupSection(
    ComboGroupModel group,
    ComboSelectionController controller,
    int unitIdx,
  ) {
    final List<ComboOptionModel> options = group.options ?? [];
    options.sort(
      (a, b) => (a.displayOrder ?? 0).compareTo(b.displayOrder ?? 0),
    );

    final int currentCount =
        controller.getGroupTotalCountForUnit(unitIdx, group.id);
    final int min = group.minSelections ?? 0;
    final int max = group.maxSelections ?? 1;

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
          (option) => _buildOptionRow(
            group,
            option,
            max,
            currentCount,
            controller,
            unitIdx,
          ),
        ),
        const Divider(),
      ],
    );
  }

  /* fila de una opción con controles +/− para la unidad indicada */
  Widget _buildOptionRow(
    ComboGroupModel group,
    ComboOptionModel option,
    int maxTotal,
    int currentTotal,
    ComboSelectionController controller,
    int unitIdx,
  ) {
    final double optionPrice = option.additionalPrice ?? 0;
    final int count =
        controller.getOptionCountForUnit(unitIdx, group.id, option.id);
    final bool canIncrement = currentTotal < maxTotal;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(option.productName ?? ''),
                if (optionPrice > 0)
                  Text(
                    '+ \$${optionPrice.toStringAsFixed(0)}',
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
