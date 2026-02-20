import 'package:flutter/material.dart';
import 'package:restic_movil/app/data/models/order_model.dart';
import 'package:intl/intl.dart';

class OrderPaymentCard extends StatelessWidget {
  final OrderModel order;
  final VoidCallback onTap;

  const OrderPaymentCard({super.key, required this.order, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final currencyFormat = NumberFormat.currency(locale: 'es_CO', symbol: '\$');
    final dateFormat = DateFormat('dd/MM/yyyy HH:mm');

    // Get color based on status
    Color statusColor;
    switch (order.status?.toUpperCase()) {
      case 'OPEN':
      case 'ABIERTA':
        statusColor = Colors.blue;
        break;
      case 'FINALIZED':
      case 'FINALIZADA':
        statusColor = Colors.green;
        break;
      case 'PAID':
      case 'PAGADA':
      case 'CERRADA':
        statusColor = Colors.purple;
        break;
      case 'CANCELED':
      case 'CANCELADA':
      case 'ANULADA':
        statusColor = Colors.red;
        break;
      default:
        statusColor = Colors.grey;
    }

    return Card(
      elevation: 4,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: statusColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: statusColor.withValues(alpha: 0.5),
                      ),
                    ),
                    child: Text(
                      order.status ?? 'Desconocido',
                      style: TextStyle(
                        color: statusColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                  Text(
                    'Orden #${order.orderNumber}',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    [
                          'TAKE_AWAY',
                          'PARA LLEVAR',
                          'DELIVERY',
                          'DOMICILIO',
                        ].contains(order.originType?.toUpperCase())
                        ? Icons.person
                        : Icons.table_restaurant,
                    size: 20,
                    color: Colors.grey,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      [
                            'TAKE_AWAY',
                            'PARA LLEVAR',
                            'DELIVERY',
                            'DOMICILIO',
                          ].contains(order.originType?.toUpperCase())
                          ? (order.customerName ??
                                order.customerId ??
                                'Cliente sin nombre')
                          : (order.tables?.map((e) => e.name).join(', ') ??
                                'Sin mesa'),
                      style: const TextStyle(fontSize: 14),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(
                    Icons.add_location_sharp,
                    size: 20,
                    color: Colors.grey,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    order.originType ?? 'Desconocido',
                    style: const TextStyle(fontSize: 14),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(Icons.access_time, size: 20, color: Colors.grey),
                  const SizedBox(width: 8),
                  Text(
                    order.openingDate != null
                        ? dateFormat.format(DateTime.parse(order.openingDate!))
                        : '-',
                    style: const TextStyle(fontSize: 14),
                  ),
                ],
              ),
              const Divider(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Total:',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                  ),
                  Text(
                    currencyFormat.format(order.total ?? 0),
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.green[700],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
