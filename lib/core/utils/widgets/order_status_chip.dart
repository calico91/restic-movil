import 'package:flutter/material.dart';

class OrderStatusChip extends StatelessWidget {
  final String? status;
  final String? label;

  const OrderStatusChip({
    super.key,
    required this.status,
    this.label,
  });

  @override
  Widget build(BuildContext context) {
    Color color = Colors.grey;
    // Usamos el status original para determinar el color
    final statusUpper = status?.toUpperCase() ?? '';

    if (statusUpper == 'ABIERTA' || statusUpper == 'OPEN') {
      color = Colors.orange;
    } else if (statusUpper == 'PAGADA' || statusUpper == 'PAID' || statusUpper == 'CERRADA') {
      color = Colors.blue;
    } else if (statusUpper == 'FINALIZADA' || statusUpper == 'FINALIZED') {
      color = Colors.green;
    } else if (statusUpper == 'ANULADA' || statusUpper == 'CANCELED' || statusUpper == 'CANCELADA') {
      color = Colors.red;
    } else {
      // Intento de compatibilidad con nombres capitalizados del switch original
      switch (status) {
        case 'Abierta':
          color = Colors.orange;
          break;
        case 'Pagada':
          color = Colors.blue;
          break;
        case 'Finalizada':
          color = Colors.green;
          break;
        case 'Anulada':
          color = Colors.red;
          break;
        default:
          color = Colors.grey;
      }
    }

    return Chip(
      label: Text(
        label ?? status ?? 'UNKNOWN',
        style: const TextStyle(color: Colors.white, fontSize: 12),
      ),
      backgroundColor: color,
      padding: EdgeInsets.zero,
      visualDensity: VisualDensity.compact,
    );
  }
}
