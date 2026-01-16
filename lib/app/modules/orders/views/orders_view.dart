import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:restic_movil/app/data/models/order_model.dart';
import 'package:restic_movil/app/modules/orders/controllers/orders_controller.dart';


class OrdersView extends GetView<OrdersController> {
  const OrdersView({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildSearchBar(),
        const SizedBox(height: 20),
        _buildCreateOrderButton(),
        const SizedBox(height: 20),
        _buildOrdersList(),
      ],
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(30),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.5),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: const TextField(
          decoration: InputDecoration(
            hintText: 'Buscar',
            prefixIcon: Icon(Icons.search, color: Colors.blue),
            border: InputBorder.none,
            contentPadding: EdgeInsets.symmetric(vertical: 15),
          ),
        ),
      ),
    );
  }

  Widget _buildCreateOrderButton() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40.0),
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: () {},
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.green[600],
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30),
            ),
            padding: const EdgeInsets.symmetric(vertical: 12),
          ),
          child: const Text(
            'Crear pedido',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildOrdersList() {
    return Expanded(
      child: Obx(() => ListView.builder(
            padding: const EdgeInsets.only(
              left: 16,
              right: 16,
              bottom: 80, // Space for the floating bottom nav
            ),
            itemCount: controller.orders.length,
            itemBuilder: (context, index) {
              final order = controller.orders[index];
              return _buildOrderCard(order);
            },
          )),
    );
  }

  Widget _buildOrderCard(OrderModel order) {
    Color statusColor;
    switch (order.status) {
      case 'Pendiente':
        statusColor = Colors.blue;
        break;
      case 'Preparando':
        statusColor = Colors.amber.shade700;
        break;
      case 'Entregado':
        statusColor = Colors.green;
        break;
      default:
        statusColor = Colors.grey;
    }

    final currencyFormat =
        NumberFormat.currency(locale: 'es_CO', symbol: '\$', decimalDigits: 0);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '#${order.id} - ${order.title}',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Row(
                children: [
                  Icon(Icons.print_outlined, color: Colors.blue[300], size: 20),
                  const SizedBox(width: 8),
                  Icon(Icons.money, color: Colors.red[300], size: 20),
                ],
              ),
            ],
          ),
          const SizedBox(height: 10),
          _buildInfoRow('Monto a pagar:', currencyFormat.format(order.amount),
              isBold: true),
          _buildInfoRow('Estado:', order.status, valueColor: statusColor),
          _buildInfoRow('Fecha y hora:', order.date),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value,
      {bool isBold = false, Color? valueColor}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(color: Colors.black87),
          ),
          Text(
            value,
            style: TextStyle(
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
              color: valueColor ?? Colors.black87,
            ),
          ),
        ],
      ),
    );
  }
}
