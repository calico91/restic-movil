import 'package:flutter/material.dart';

/// Badge reutilizable que muestra el estado de una conexion
/// (conectado en verde / desconectado en gris) con un label descriptivo.
class StatusBadge extends StatelessWidget {
  final bool connected;
  final String label;

  const StatusBadge({
    super.key,
    required this.connected,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: connected
            ? Colors.green.withValues(alpha: 0.1)
            : Colors.grey.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: connected
              ? Colors.green.withValues(alpha: 0.4)
              : Colors.grey.shade300,
        ),
      ),
      child: Row(
        children: [
          Icon(
            connected ? Icons.circle : Icons.circle_outlined,
            size: 12,
            color: connected ? Colors.green : Colors.grey,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 13,
                color: connected ? Colors.green.shade700 : Colors.grey,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
