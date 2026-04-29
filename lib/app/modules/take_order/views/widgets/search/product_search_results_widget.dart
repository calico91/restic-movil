import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:restic_movil/app/data/models/price_model.dart';
import 'package:restic_movil/app/data/models/product_model.dart';
import 'package:restic_movil/app/modules/take_order/controllers/take_order_controller.dart';
import 'package:restic_movil/core/utils/widgets/expandable_section.dart';

/// Lista plana de resultados de búsqueda de productos con breadcrumb de categoría.
class ProductSearchResultsWidget extends GetView<TakeOrderController> {
  final void Function(ProductModel, PriceModel?) onIncrement;
  final void Function(ProductModel, PriceModel?) onDecrement;
  final void Function(ProductModel, PriceModel?) onEdit;

  const ProductSearchResultsWidget({
    super.key,
    required this.onIncrement,
    required this.onDecrement,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final List<(ProductModel, String, String?)> results =
          controller.searchResults;

      if (results.isEmpty) {
        return const Padding(
          padding: EdgeInsets.symmetric(vertical: 24),
          child: Center(
            child: Text(
              'No se encontraron productos.',
              style: TextStyle(color: Colors.grey, fontStyle: FontStyle.italic),
            ),
          ),
        );
      }

      return ExpandableSection(
        title: 'Resultados (${results.length})',
        icon: Icons.search,
        initiallyExpanded: true,
        content: ListView.builder(
          padding: EdgeInsets.zero,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: results.length,
          itemBuilder: (context, index) {
            final (
              ProductModel product,
              String categoryName,
              String? subcategoryName,
            ) = results[index];

            if (product.productType == 'VARIABLE' &&
                (product.prices?.isNotEmpty ?? false)) {
              return _buildVariableRow(
                context,
                product,
                categoryName,
                subcategoryName,
              );
            }

            final PriceModel? price =
                (product.prices?.isNotEmpty ?? false)
                    ? product.prices!.first
                    : null;

            return _buildSingleRow(
              context,
              product,
              price,
              categoryName,
              subcategoryName,
            );
          },
        ),
      );
    });
  }

  /// Fila para producto simple o combo.
  Widget _buildSingleRow(
    BuildContext context,
    ProductModel product,
    PriceModel? price,
    String categoryName,
    String? subcategoryName,
  ) {
    final bool isCombo = product.productType == 'COMBO';
    return Obx(() {
      final int quantity = controller.getProductQuantity(product, price);
      return Container(
        margin: const EdgeInsets.only(bottom: 8),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(color: Colors.grey[200]!, width: 1),
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
                      subcategoryName != null
                          ? '$categoryName › $subcategoryName'
                          : categoryName,
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.grey[500],
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      product.name ?? '',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    if (product.description != null &&
                        product.description!.isNotEmpty)
                      Text(
                        product.description!,
                        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                      ),
                    const SizedBox(height: 4),
                    Text(
                      '\$${price?.amount?.toStringAsFixed(0) ?? '0'}',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.green,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
              if (isCombo)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    ElevatedButton(
                      onPressed: () => onIncrement(product, price),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue[900],
                        foregroundColor: Colors.white,
                        minimumSize: const Size(80, 36),
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                      ),
                      child: const Text('Configurar'),
                    ),
                    if (quantity > 0)
                      Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Text(
                          '$quantity en pedido',
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.blue,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                  ],
                )
              else
                Row(
                  children: [
                    if (quantity > 0) ...[
                      IconButton(
                        icon: const Icon(
                          Icons.remove_circle_outline,
                          color: Colors.red,
                        ),
                        onPressed: () => onDecrement(product, price),
                      ),
                      GestureDetector(
                        onTap: () => onEdit(product, price),
                        child: Text(
                          '$quantity',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                    IconButton(
                      icon: Icon(
                        Icons.add_circle_outline,
                        color: Colors.blue[900],
                      ),
                      onPressed: () => onEdit(product, price),
                    ),
                  ],
                ),
            ],
          ),
        ),
      );
    });
  }

  /// Fila para producto variable con múltiples tallas/precios.
  Widget _buildVariableRow(
    BuildContext context,
    ProductModel product,
    String categoryName,
    String? subcategoryName,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Colors.grey[200]!, width: 1),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              subcategoryName != null
                  ? '$categoryName › $subcategoryName'
                  : categoryName,
              style: TextStyle(
                fontSize: 11,
                color: Colors.grey[500],
                fontStyle: FontStyle.italic,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              product.name ?? '',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
            if (product.description != null && product.description!.isNotEmpty)
              Text(
                product.description!,
                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
              ),
            const SizedBox(height: 12),
            ...product.prices!.map((PriceModel price) {
              return Obx(() {
                final int quantity =
                    controller.getProductQuantity(product, price);
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12.0, left: 8.0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              price.sizeLabel ?? '',
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              '\$${price.amount?.toStringAsFixed(0) ?? '0'}',
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
                          if (quantity > 0) ...[
                            IconButton(
                              icon: const Icon(
                                Icons.remove_circle_outline,
                                color: Colors.red,
                              ),
                              onPressed: () => onDecrement(product, price),
                            ),
                            GestureDetector(
                              onTap: () => onEdit(product, price),
                              child: Text(
                                '$quantity',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                          IconButton(
                            icon: Icon(
                              Icons.add_circle_outline,
                              color: Colors.blue[900],
                            ),
                            onPressed: () => onEdit(product, price),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              });
            }),
          ],
        ),
      ),
    );
  }
}
