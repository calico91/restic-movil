import 'package:flutter/material.dart';
import 'package:restic_movil/app/data/models/associated_product_model.dart';
import 'package:restic_movil/app/data/models/inventory_item_model.dart';

class AssociatedProductsDialog extends StatelessWidget {
  final InventoryItemModel item;
  final List<AssociatedProductModel> products;

  const AssociatedProductsDialog({
    super.key,
    required this.item,
    required this.products,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: Column(
        children: [
          const Icon(Icons.restaurant_menu, color: Color(0xFF0D47A1), size: 40),
          const SizedBox(height: 8),
          const Text('Productos asociados'),
          const SizedBox(height: 4),
          Text(
            item.name ?? '',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w400,
              color: Colors.black54,
            ),
          ),
        ],
      ),
      content: SizedBox(
        width: double.maxFinite,
        child: products.isEmpty
            ? const Padding(
                padding: EdgeInsets.symmetric(vertical: 24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.info_outline, color: Colors.grey, size: 48),
                    SizedBox(height: 12),
                    Text(
                      'El insumo no esta asociado a productos.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.black54),
                    ),
                  ],
                ),
              )
            : ListView.separated(
                shrinkWrap: true,
                itemCount: products.length,
                separatorBuilder: (_, __) => const Divider(height: 1),
                itemBuilder: (context, index) {
                  final p = products[index];
                  final label = p.priceVariantLabel != null
                      ? '${p.productName} · ${p.priceVariantLabel}'
                      : p.productName ?? '-';
                  return ListTile(
                    dense: true,
                    leading: CircleAvatar(
                      radius: 16,
                      backgroundColor: const Color(0xFF0D47A1).withValues(alpha: 0.1),
                      child: const Icon(
                        Icons.fastfood,
                        size: 16,
                        color: Color(0xFF0D47A1),
                      ),
                    ),
                    title: Text(label),
                    subtitle: Text(
                      '${p.productType ?? '-'} · Cantidad: ${p.quantity ?? 0}',
                      style: const TextStyle(fontSize: 12),
                    ),
                  );
                },
              ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cerrar'),
        ),
      ],
    );
  }
}
