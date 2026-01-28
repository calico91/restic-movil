import 'package:flutter/material.dart';
import 'package:restic_movil/app/data/models/category_model.dart';
import 'package:restic_movil/core/utils/widgets/expandable_section.dart';

class ProductSelectionWidget extends StatelessWidget {
  final List<CategoryModel> categories;
  final int Function(ProductModel) getQuantity;
  final void Function(ProductModel) onIncrement;
  final void Function(ProductModel) onDecrement;
  final void Function(ProductModel) onEdit;
  final bool initiallyExpanded;

  const ProductSelectionWidget({
    super.key,
    required this.categories,
    required this.getQuantity,
    required this.onIncrement,
    required this.onDecrement,
    required this.onEdit,
    this.initiallyExpanded = true,
  });

  @override
  Widget build(BuildContext context) {
    if (categories.isEmpty) return const SizedBox.shrink();

    return ExpandableSection(
      title: 'Productos',
      icon: Icons.fastfood,
      initiallyExpanded: initiallyExpanded,
      content: ListView.builder(
        padding: EdgeInsets.zero,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: categories.length,
        itemBuilder: (context, index) {
          final category = categories[index];
          return _buildCategoryTile(category);
        },
      ),
    );
  }

  Widget _buildCategoryTile(CategoryModel category) {
    return ExpansionTile(
      title: Text(
        category.name ?? '',
        style: const TextStyle(fontWeight: FontWeight.bold),
      ),
      childrenPadding: const EdgeInsets.only(left: 16),
      children: category.subcategories?.map((subcategory) {
        return ExpansionTile(
          title: Text(
            subcategory.name ?? '',
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
          subtitle: Text(subcategory.description ?? ''),
          childrenPadding: const EdgeInsets.only(left: 16),
          children: subcategory.products?.map((product) {
            return _buildProductRow(product);
          }).toList() ?? [],
        );
      }).toList() ?? [],
    );
  }

  Widget _buildProductRow(ProductModel product) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: Colors.grey[200]!,
            width: 1,
          ),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.name ?? '',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  if (product.description != null)
                    Text(
                      product.description!,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                  const SizedBox(height: 4),
                  Text(
                    '\$${product.price?.amount?.toStringAsFixed(0) ?? '0'}',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.green,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
            Row(
              children: [
                IconButton(
                  onPressed: () => onEdit(product),
                  icon: const Icon(
                    Icons.edit_note,
                    color: Colors.orange,
                  ),
                  tooltip: 'Agregar con notas',
                ),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    children: [
                      IconButton(
                        icon: const Icon(
                          Icons.remove,
                          color: Colors.red,
                          size: 20,
                        ),
                        onPressed: () => onDecrement(product),
                        constraints: const BoxConstraints(
                          minWidth: 36,
                          minHeight: 36,
                        ),
                        padding: EdgeInsets.zero,
                      ),
                      // Usamos Obx indirectamente si el padre redibuja, 
                      // pero para ser seguros si getQuantity no es reactivo per se en este scope,
                      // dependemos del padre y sus Obx.
                      // Sin embargo, si getQuantity accede a un .value de un Rx, GetX lo trackea si estamos dentro de un Obx.
                      // Aquí NO estamos dentro de un Obx explícito, así que esperamos que el padre envuelva ProductSelectionWidget con Obx.
                      Text(
                        '${getQuantity(product)}',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(
                          Icons.add,
                          color: Colors.green,
                          size: 20,
                        ),
                        onPressed: () => onIncrement(product),
                        constraints: const BoxConstraints(
                          minWidth: 36,
                          minHeight: 36,
                        ),
                        padding: EdgeInsets.zero,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
