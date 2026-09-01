import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:restic_movil/app/data/models/category_model.dart';
import 'package:restic_movil/app/modules/reports/controllers/reports_controller.dart';

class ProductSelectionSection extends StatelessWidget {
  const ProductSelectionSection({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<ReportsController>();
    const color = Color(0xFF0D47A1);

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Obx(() => Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.checklist, color: color),
                    const SizedBox(width: 8),
                    const Expanded(
                      child: Text(
                        'Selecciona los productos a consultar',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Obx(() => Text(
                          '${controller.selectedProductIds.length} seleccionados',
                          style: const TextStyle(
                            color: color,
                            fontWeight: FontWeight.w600,
                            fontSize: 12,
                          ),
                        )),
                  ],
                ),
                const SizedBox(height: 8),
                if (controller.isLoadingCategories.value)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 24),
                    child: Center(child: CircularProgressIndicator()),
                  )
                else if (controller.categories.isEmpty)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 16),
                    child: Text('No hay categorías con productos disponibles'),
                  )
                else
                  _buildCategoryTree(context, controller),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: Obx(() => ElevatedButton.icon(
                            onPressed: controller.selectedProductIds.isEmpty
                                ? null
                                : () => controller.fetchReport(),
                            icon: const Icon(Icons.search),
                            label: const Text('Consultar reporte'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: color,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                          )),
                    ),
                    const SizedBox(width: 8),
                    OutlinedButton.icon(
                      onPressed: () => controller.clearProductSelection(),
                      icon: const Icon(Icons.clear),
                      label: const Text('Limpiar'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: color,
                        side: const BorderSide(color: color),
                        padding: const EdgeInsets.symmetric(
                          vertical: 14,
                          horizontal: 12,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            )),
      ),
    );
  }

  Widget _buildCategoryTree(BuildContext context, ReportsController controller) {
    const color = Color(0xFF0D47A1);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (final category in controller.categories)
          _CategoryGroup(category: category),
        const SizedBox(height: 8),
        Row(
          children: [
            const Expanded(child: SizedBox.shrink()),
            TextButton.icon(
              onPressed: () {
                for (final cat in controller.categories) {
                  for (final sub in cat.subcategories ?? <SubcategoryModel>[]) {
                    final ids = sub.products?.map((p) => p.id ?? '').toList() ?? [];
                    if (ids.isNotEmpty) controller.toggleSubcategory(sub.id, ids);
                  }
                }
              },
              icon: const Icon(Icons.select_all, color: color),
              label: const Text('Seleccionar todos', style: TextStyle(color: color)),
            ),
          ],
        ),
      ],
    );
  }
}

class _CategoryGroup extends StatelessWidget {
  const _CategoryGroup({required this.category});
  final CategoryModel category;

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: Theme.of(context).copyWith(
        dividerColor: Colors.transparent,
        splashFactory: NoSplash.splashFactory,
        highlightColor: Colors.transparent,
      ),
      child: ExpansionTile(
        tilePadding: const EdgeInsets.symmetric(horizontal: 0),
        childrenPadding: const EdgeInsets.symmetric(horizontal: 0),
        initiallyExpanded: false,
        leading: const Icon(Icons.restaurant_menu, color: Color(0xFF0D47A1)),
        title: Text(
          category.name ?? 'Sin nombre',
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
        ),
        children: [
          for (final sub in category.subcategories ?? const <SubcategoryModel>[])
            _SubcategoryGroup(subcategory: sub),
        ],
      ),
    );
  }
}

class _SubcategoryGroup extends StatelessWidget {
  const _SubcategoryGroup({required this.subcategory});
  final SubcategoryModel subcategory;

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<ReportsController>();
    final products = subcategory.products ?? const [];
    final productIds = products.map((p) => p.id ?? '').where((id) => id.isNotEmpty).toList();
    const color = Color(0xFF0D47A1);

    if (products.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 16, top: 4, bottom: 4),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    subcategory.name ?? 'Sin subcategoría',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey,
                    ),
                  ),
                ),
                Obx(() {
                  final allSelected = controller.isSubcategoryFullySelected(productIds);
                  final partial = controller.isSubcategoryPartiallySelected(productIds);
                  return Checkbox(
                    value: allSelected,
                    tristate: partial,
                    onChanged: (_) =>
                        controller.toggleSubcategory(subcategory.id, productIds),
                    activeColor: color,
                    visualDensity: VisualDensity.compact,
                  );
                }),
              ],
            ),
          ),
          ...products.map((p) {
            final id = p.id ?? '';
            if (id.isEmpty) return const SizedBox.shrink();
            return Obx(() => CheckboxListTile(
                  value: controller.isProductSelected(id),
                  onChanged: (_) => controller.toggleProduct(id),
                  title: Text(p.name ?? 'Sin nombre'),
                  controlAffinity: ListTileControlAffinity.leading,
                  activeColor: color,
                  dense: true,
                  contentPadding: const EdgeInsets.only(left: 32, right: 8),
                ));
          }),
        ],
      ),
    );
  }
}
