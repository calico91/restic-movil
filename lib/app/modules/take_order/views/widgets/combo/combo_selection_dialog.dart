import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:restic_movil/app/data/models/combo_group_model.dart';
import 'package:restic_movil/app/data/models/combo_option_model.dart';
import 'package:restic_movil/app/data/models/order_item_model.dart';
import 'package:restic_movil/app/data/models/price_model.dart';
import 'package:restic_movil/app/data/models/product_model.dart';
import 'package:restic_movil/app/modules/take_order/controllers/combo_selection_controller.dart';

class ComboSelectionDialog extends StatelessWidget {
  final ProductModel product;
  final PriceModel? price;
  // Retorna el OrderItemModel creado/reemplazado; recibe previousItem para edición
  final OrderItemModel? Function(
    ProductModel,
    PriceModel?,
    int,
    String,
    List<Map<String, String>>,
    double,
    OrderItemModel?,
  ) onConfirm;

  const ComboSelectionDialog({
    super.key,
    required this.product,
    this.price,
    required this.onConfirm,
  });

  @override
  Widget build(BuildContext context) {
    final String tag = 'combo_${product.id}';
    // Registra el controller solo si no existe, con permanent:true para que GetX
    // no lo elimine al cerrar la ruta del diálogo (removeDependencyByRoute)
    if (!Get.isRegistered<ComboSelectionController>(tag: tag)) {
      Get.put(
        ComboSelectionController(product: product, price: price, onConfirm: onConfirm),
        tag: tag,
        permanent: true,
      );
    }
    return GetBuilder<ComboSelectionController>(
      tag: tag,
      autoRemove: false, // No eliminar al cerrar; persiste hasta confirmar el pedido
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

                  // Resumen de lo seleccionado para la unidad activa
                  _buildCurrentUnitSummary(controller),

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

/* banner reactivo con los productos ya seleccionados en la unidad activa */
  Widget _buildCurrentUnitSummary(ComboSelectionController controller) {
    return Obx(() {
      final int unitIdx = controller.currentUnit.value;
      if (unitIdx >= controller.unitSelections.length) {
        return const SizedBox.shrink();
      }
      final Map<String, Map<String, int>> unitSel =
          controller.unitSelections[unitIdx];
      if (unitSel.isEmpty) return const SizedBox.shrink();

      // Construir lista de nombres con cantidad (si > 1)
      final List<String> names = [];
      for (final ComboGroupModel group in product.comboGroups ?? []) {
        final Map<String, int> groupOptions = unitSel[group.id] ?? {};
        groupOptions.forEach((String optionId, int count) {
          if (count > 0) {
            final ComboOptionModel? option =
                group.options?.where((o) => o.id == optionId).firstOrNull;
            if (option?.productName != null) {
              names.add(
                count > 1
                    ? '${option!.productName!} ×$count'
                    : option!.productName!,
              );
            }
          }
        });
      }

      if (names.isEmpty) return const SizedBox.shrink();

      return Container(
        width: double.infinity,
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: const Color(0xFFE3F2FD),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: const Color(0xFF90CAF9)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Selección actual:',
              style: TextStyle(
                fontSize: 11,
                color: Color(0xFF1565C0),
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 6),
            Wrap(
              spacing: 6,
              runSpacing: 4,
              children: names
                  .map(
                    (String name) => Chip(
                      label: Text(
                        name,
                        style: const TextStyle(fontSize: 12),
                      ),
                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      visualDensity: VisualDensity.compact,
                      backgroundColor: Colors.white,
                      side: const BorderSide(color: Color(0xFF90CAF9)),
                      padding: EdgeInsets.zero,
                    ),
                  )
                  .toList(),
            ),
          ],
        ),
      );
    });
  }

/* navegador de unidades: chips numerados a la izquierda, botones +/- fijos a la derecha */
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
          Row(
            children: [
              // Chips en área con scroll horizontal
              Expanded(
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
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
                    ],
                  ),
                ),
              ),

              // Botones fijos a la derecha
              // Botón quitar última unidad (solo si hay más de una)
              if (total > 1) ...[  
                IconButton(
                  icon: Icon(Icons.remove_circle, color: Colors.red[700]),
                  tooltip: 'Quitar último combo',
                  onPressed: controller.removeUnit,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
                const SizedBox(width: 4),
              ],
              // Botón agregar unidad (siempre a la derecha)
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
            ],
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
    final List<ComboOptionModel> options = (group.options ?? [])
        .where((o) => o.available != false)
        .toList();
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
