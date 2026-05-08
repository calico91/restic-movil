import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:restic_movil/app/data/models/category_model.dart';
import 'package:restic_movil/core/utils/widgets/expandable_section.dart';

class ProductSelectionWidget extends StatelessWidget {
  final List<CategoryModel> categories;
  final int Function(ProductModel, PriceModel?) getQuantity;
  final void Function(ProductModel, PriceModel?) onIncrement;
  final void Function(ProductModel, PriceModel?) onDecrement;
  final void Function(ProductModel, PriceModel?) onEdit;
  // Callback para productos COMBINADO: producto seleccionado + lista de hermanos posibles
  final void Function(ProductModel, List<ProductModel>)? onCombine;
  // Callback para decrementar combinaciones COMBINADO
  final void Function(ProductModel)? onDecrementCombination;
  // Callback para obtener la cantidad de combinaciones activas
  final int Function(ProductModel)? getCombinationQuantity;
  final bool initiallyExpanded;

  const ProductSelectionWidget({
    super.key,
    required this.categories,
    required this.getQuantity,
    required this.onIncrement,
    required this.onDecrement,
    required this.onEdit,
    this.onCombine,
    this.onDecrementCombination,
    this.getCombinationQuantity,
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
    final subcategories = category.subcategories ?? [];
    List<Widget> childrenWidgets = [];

    if (subcategories.length == 1) {
      // Si solo hay una subcategoría, mostrar los productos directamente
      final singleSub = subcategories.first;
      final products = singleSub.products ?? [];
      childrenWidgets = products.map((product) {
        return _buildProductRow(product, products);
      }).toList();
    } else if (subcategories.length > 1) {
      // Si hay múltiples subcategorías, mantener los ExpansionTile
      childrenWidgets = subcategories.map((subcategory) {
        final subProducts = subcategory.products ?? [];
        return ExpansionTile(
          title: Text(
            subcategory.name ?? '',
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
          subtitle: Text(subcategory.description ?? ''),
          childrenPadding: const EdgeInsets.only(left: 16),
          children:
              subProducts.map((product) {
                return _buildProductRow(product, subProducts);
              }).toList(),
        );
      }).toList();
    }

    return ExpansionTile(
      title: Text(
        category.name ?? '',
        style: const TextStyle(fontWeight: FontWeight.bold),
      ),
      childrenPadding: const EdgeInsets.only(left: 16),
      children: childrenWidgets,
    );
  }

  // Construye la fila para un producto según su tipo; recibe los productos del mismo subcategory
  Widget _buildProductRow(ProductModel product, List<ProductModel> subcategoryProducts) {
    if (product.productType == 'COMBINADO') {
      // Hermanos = todos los COMBINADO del mismo subcategoryId excepto el actual
      final List<ProductModel> siblings = subcategoryProducts
          .where((p) => p.productType == 'COMBINADO' && p.id != product.id)
          .toList();
      return _buildCombinadoProductRow(product, siblings);
    } else if (product.productType == 'VARIABLE' && (product.prices?.isNotEmpty ?? false)) {
      return _buildVariableProductRow(product);
    } else {
      final price = (product.prices?.isNotEmpty ?? false) ? product.prices!.first : null;
      return _buildSingleProductRow(product, price);
    }
  }

  Widget _buildVariableProductRow(ProductModel product) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: Colors.grey[200]!, width: 1)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
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
            if (product.description != null && product.description!.isNotEmpty) ...[
              const SizedBox(height: 4),
              Text(
                product.description!,
                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
              ),
            ],
            const SizedBox(height: 12),
            ...product.prices!.map((price) {
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
                    _buildStandardActions(product, price),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildSingleProductRow(ProductModel product, PriceModel? price) {
    final isCombo = product.productType == 'COMBO';
    final quantity = getQuantity(product, price);

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: Colors.grey[200]!, width: 1)),
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
                    product.productType == 'VARIABLE' && price?.sizeLabel != null
                        ? '${product.name ?? ''} - ${price!.sizeLabel}'
                        : product.name ?? '',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  if (product.description != null)
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
              _buildComboActions(product, price, quantity)
            else
              _buildStandardActions(product, price),
          ],
        ),
      ),
    );
  }

  Widget _buildComboActions(ProductModel product, PriceModel? price, int quantity) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        ElevatedButton(
          onPressed: () => onIncrement(
            product,
            price,
          ), // Usamos onIncrement para activar el diálogo
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
    );
  }

  Widget _buildStandardActions(ProductModel product, PriceModel? price) {
    return Row(
      children: [
        IconButton(
          onPressed: () => onEdit(product, price),
          icon: const Icon(Icons.edit_note, color: Colors.orange),
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
                icon: const Icon(Icons.remove, color: Colors.red, size: 20),
                onPressed: () => onDecrement(product, price),
                constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
                padding: EdgeInsets.zero,
              ),
              Obx(
                () => Text(
                  '${getQuantity(product, price)}',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.add, color: Colors.green, size: 20),
                onPressed: () => onIncrement(product, price),
                constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
                padding: EdgeInsets.zero,
              ),
            ],
          ),
        ),
      ],
    );
  }

  // Fila especial para productos COMBINADO: controles individuales estándar + botón opcional de combinación 2×1.
  // Usa un único Obx para todo el bloque de controles, garantizando que getQuantity registre
  // la dependencia reactiva en currentOrder incluso cuando no hay combinaciones activas.
  Widget _buildCombinadoProductRow(ProductModel product, List<ProductModel> siblings) {
    final PriceModel? price =
        product.prices?.isNotEmpty == true ? product.prices!.first : null;
    final double priceAmount = price?.amount ?? 0;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: Colors.grey[200]!, width: 1)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Info del producto: nombre, descripción, precio y chip COMBINADO
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.name ?? '',
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                  ),
                  if (product.description != null && product.description!.isNotEmpty)
                    Text(
                      product.description!,
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                    ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Text(
                        '\$${priceAmount.toStringAsFixed(0)}',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.green,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(width: 8),
                      // Chip identificador de tipo COMBINADO
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.blue[900],
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Text(
                          '2×1 COMBINADO',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            // Único Obx que cubre cantidad individual Y combinaciones para garantizar
            // que getQuantity registre la dependencia reactiva en currentOrder.
            Obx(() {
              final int qty = getQuantity(product, price);
              final int comboQty = getCombinationQuantity?.call(product) ?? 0;

              return Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  // Controles estándar: editar, decrementar, cantidad, incrementar
                  Row(
                    children: [
                      IconButton(
                        onPressed: () => onEdit(product, price),
                        icon: const Icon(Icons.edit_note, color: Colors.orange),
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
                              icon: const Icon(Icons.remove, color: Colors.red, size: 20),
                              onPressed: () => onDecrement(product, price),
                              constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
                              padding: EdgeInsets.zero,
                            ),
                            Text(
                              '$qty',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.add, color: Colors.green, size: 20),
                              onPressed: () => onIncrement(product, price),
                              constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
                              padding: EdgeInsets.zero,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  // Sección de combinación 2×1 (solo si existen hermanos combinables)
                  if (siblings.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    if (comboQty > 0)
                      // Hay combinaciones activas: muestra [-][qty 2×1][🔗]
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.link_off, color: Colors.red, size: 18),
                            onPressed: () => onDecrementCombination?.call(product),
                            constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                            padding: EdgeInsets.zero,
                            tooltip: 'Quitar combinación',
                          ),
                          Text(
                            '$comboQty 2×1',
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: Colors.blue,
                            ),
                          ),
                          const SizedBox(width: 4),
                          // Agregar otra combinación
                          ElevatedButton.icon(
                            onPressed: onCombine != null
                                ? () => onCombine!(product, siblings)
                                : null,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue[900],
                              foregroundColor: Colors.white,
                              minimumSize: const Size(36, 28),
                              padding: const EdgeInsets.symmetric(horizontal: 8),
                            ),
                            icon: const Icon(Icons.link, size: 14),
                            label: const SizedBox.shrink(),
                          ),
                        ],
                      )
                    else
                      // Sin combinaciones activas: botón opcional para combinar
                      ElevatedButton.icon(
                        onPressed: onCombine != null
                            ? () => onCombine!(product, siblings)
                            : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue[900],
                          foregroundColor: Colors.white,
                          minimumSize: const Size(80, 28),
                          padding: const EdgeInsets.symmetric(horizontal: 10),
                        ),
                        icon: const Icon(Icons.link, size: 14),
                        label: const Text('2×1', style: TextStyle(fontSize: 12)),
                      ),
                  ],
                ],
              );
            }),
          ],
        ),
      ),
    );
  }
}
