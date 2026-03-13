import 'package:flutter/material.dart';
import 'package:restic_movil/app/data/models/order_model.dart';
import 'package:restic_movil/core/utils/buttons/card_buttons.dart';
import 'package:restic_movil/core/utils/modals/global_order_details_modal.dart';
import 'package:restic_movil/core/utils/widgets/order_status_chip.dart';
import 'package:restic_movil/core/utils/formatters/currency_formatter.dart';
import 'package:intl/intl.dart';

class OrderPaymentCard extends StatelessWidget {
  final OrderModel order;
  final VoidCallback onTap;
  final bool showPaymentButton;

  const OrderPaymentCard({
    super.key,
    required this.order,
    required this.onTap,
    this.showPaymentButton = true,
  });

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('dd/MM/yyyy HH:mm');

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                OrderStatusChip(status: order.status),
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
                  CurrencyFormatter.toCurrency(order.total ?? 0),
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.green[700],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            // Botones de acción
            Row(
              children: [
                Expanded(
                  child: CardPrimaryButton(
                    text: 'Detalle Pedido',
                    onPressed: () => GlobalOrderDetailsModal.show(
                      context: context,
                      order: order,
                      isReadOnly: true,
                    ),
                  ),
                ),
                if (showPaymentButton) ...[
                  const SizedBox(width: 10),
                  Expanded(
                    child: CardOutlinedButton(text: 'Pagar', onPressed: onTap),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}
