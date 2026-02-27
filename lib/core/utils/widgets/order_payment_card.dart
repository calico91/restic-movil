import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:restic_movil/app/data/models/order_model.dart';
import 'package:intl/intl.dart';
import 'package:restic_movil/core/utils/buttons/card_buttons.dart';
import 'package:restic_movil/core/utils/widgets/order_status_chip.dart';

class OrderPaymentCard extends StatelessWidget {
  final OrderModel order;
  final VoidCallback onTap;

  const OrderPaymentCard({super.key, required this.order, required this.onTap});

  /*muestra el modal de detalle del pedido con sus productos y precios*/
  void _showOrderDetail(BuildContext context, NumberFormat currencyFormat) {
    final details = order.details ?? [];

    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            const Icon(Icons.receipt_long_outlined, color: Colors.blue),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                'Detalle Orden #${order.orderNumber}',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        content: SizedBox(
          width: double.maxFinite,
          child: details.isEmpty
              ? const Center(child: Text('Sin productos registrados'))
              : Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Encabezado
                    const Row(
                      children: [
                        Expanded(
                          flex: 4,
                          child: Text(
                            'Producto',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                            ),
                          ),
                        ),
                        SizedBox(
                          width: 36,
                          child: Text(
                            'Cant.',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                            ),
                          ),
                        ),
                        Expanded(
                          flex: 3,
                          child: Text(
                            'Subtotal',
                            textAlign: TextAlign.right,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const Divider(),
                    // Lista de productos
                    ConstrainedBox(
                      constraints: BoxConstraints(maxHeight: Get.height * 0.4),
                      child: ListView.separated(
                        shrinkWrap: true,
                        itemCount: details.length,
                        separatorBuilder: (_, _) => const Divider(height: 1),
                        itemBuilder: (context, index) {
                          final detail = details[index];
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 6),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  flex: 4,
                                  child: Text(
                                    detail.productName ?? '-',
                                    style: const TextStyle(fontSize: 13),
                                  ),
                                ),
                                SizedBox(
                                  width: 36,
                                  child: Text(
                                    'x${detail.quantity ?? 0}',
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(
                                      fontSize: 13,
                                      color: Colors.grey,
                                    ),
                                  ),
                                ),
                                Expanded(
                                  flex: 3,
                                  child: Text(
                                    currencyFormat.format(detail.subtotal ?? 0),
                                    textAlign: TextAlign.right,
                                    style: const TextStyle(fontSize: 13),
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                    const Divider(),
                    // Total
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Total:',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                          ),
                        ),
                        Text(
                          currencyFormat.format(order.total ?? 0),
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                            color: Colors.green[700],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
        ),
        actions: [
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => Get.back(),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue[900],
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Text(
                'Cerrar',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final currencyFormat = NumberFormat.currency(
      locale: 'es_CO',
      symbol: '\$',
      decimalDigits: 0,
    );
    final dateFormat = DateFormat('dd/MM/yyyy HH:mm');

    return Card(
      elevation: 4,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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
                  currencyFormat.format(order.total ?? 0),
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
                    onPressed: () => _showOrderDetail(context, currencyFormat),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: CardOutlinedButton(text: 'Pagar', onPressed: onTap),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
