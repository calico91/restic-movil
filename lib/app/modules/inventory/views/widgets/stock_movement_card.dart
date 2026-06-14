import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:restic_movil/app/data/models/stock_movement_model.dart';

class StockMovementCard extends StatelessWidget {
  final StockMovementModel movement;

  const StockMovementCard({super.key, required this.movement});

  @override
  Widget build(BuildContext context) {
    final bool isOutput = movement.type == 'SALE' ||
        movement.type == 'WASTE' ||
        movement.type == 'ADJUSTMENT_NEGATIVE';

    final Color color = isOutput ? Colors.red : const Color(0xFF0D47A1);
    final IconData icon = isOutput ? Icons.arrow_downward : Icons.arrow_upward;

    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: color.withOpacity(0.12),
          child: Icon(icon, color: color),
        ),
        title: Text(movement.inventoryItemName ?? '-'),
        subtitle: Text(
          '${movement.type ?? '-'} | ${movement.createdAt != null ? DateFormat('dd/MM/yyyy HH:mm').format(movement.createdAt!) : '-'}',
        ),
        trailing: Text(
          '${movement.quantity ?? 0}',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ),
    );
  }
}
