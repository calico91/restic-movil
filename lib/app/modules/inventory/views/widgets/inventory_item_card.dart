import 'package:flutter/material.dart';
import 'package:restic_movil/app/data/models/inventory_item_model.dart';

class InventoryItemCard extends StatelessWidget {
  final InventoryItemModel item;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final VoidCallback? onViewProducts;

  const InventoryItemCard({
    super.key,
    required this.item,
    this.onEdit,
    this.onDelete,
    this.onViewProducts,
  });

  @override
  Widget build(BuildContext context) {
    final Color statusColor = switch (item.stockStatus) {
      'OUT' => Colors.red,
      'LOW' => Colors.orange,
      _ => Colors.green,
    };

    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: statusColor.withValues(alpha: 0.15),
          child: Icon(Icons.inventory_2_outlined, color: statusColor),
        ),
        title: Text(item.name ?? '-'),
        subtitle: Text(
          'Stock: ${item.currentStock ?? 0} ${item.unit ?? ''} | Min: ${item.minStock ?? 0}',
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (onViewProducts != null)
              IconButton(
                onPressed: onViewProducts,
                icon: const Icon(Icons.restaurant_menu, color: Color(0xFF0D47A1)),
              ),
            if (onEdit != null)
              IconButton(
                onPressed: onEdit,
                icon: const Icon(Icons.edit, color: Color(0xFF0D47A1)),
              ),
            if (onDelete != null)
              IconButton(
                onPressed: onDelete,
                icon: const Icon(Icons.delete_outline, color: Colors.red),
              ),
          ],
        ),
      ),
    );
  }
}
