import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:restic_movil/app/data/models/order_model.dart';
import 'package:restic_movil/app/modules/orders/controllers/orders_controller.dart';
import 'package:restic_movil/app/routes/app_routes.dart';
import 'package:restic_movil/core/utils/modals/order_details_modal.dart';

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

  /*build barra de busqueda*/
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
        child: TextField(
          controller: controller.searchController,
          decoration: const InputDecoration(
            hintText: 'Buscar por mesa',
            prefixIcon: Icon(Icons.search, color: Colors.blue),
            border: InputBorder.none,
            contentPadding: EdgeInsets.symmetric(vertical: 15),
          ),
        ),
      ),
    );
  }

  /*build boton crear pedido*/
  Widget _buildCreateOrderButton() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40.0),
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: () {
            Get.toNamed(Routes.TAKE_ORDER);
          },
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

  /*build lista de pedidos*/
  Widget _buildOrdersList() {
    return Expanded(
      child: RefreshIndicator(
        onRefresh: () async => await controller.loadOrders(withOverlay: false),
        child: Obx(
          () => ListView.builder(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.only(
              left: 16,
              right: 16,
              bottom: 80, // Space for the floating bottom nav
            ),
            itemCount: controller.orders.length,
            itemBuilder: (context, index) {
              final order = controller.orders[index];
              return _buildOrderCard(context, order);
            },
          ),
        ),
      ),
    );
  }

  /*build tarjeta de pedido*/
  Widget _buildOrderCard(BuildContext context, OrderModel order) {
    Color statusColor;
    String statusText = order.status ?? '';

    switch (statusText.toUpperCase()) {
      case 'PENDING':
      case 'OPEN':
        statusColor = Colors.orange;
        statusText = 'Abierto';
        break;
      case 'PREPARING':
        statusColor = Colors.blue;
        statusText = 'Preparando';
        break;
      case 'READY':
      case 'SERVED':
      case 'DELIVERED':
        statusColor = Colors.green;
        statusText = 'Entregado';
        break;
      default:
        statusColor = Colors.grey;
    }

    final currencyFormat = NumberFormat.currency(
      locale: 'es_CO',
      symbol: '\$',
      decimalDigits: 0,
    );

    // Formatear fecha
    String dateText = '';
    if (order.openingDate != null) {
      try {
        final date = DateTime.parse(order.openingDate!);
        dateText = DateFormat('dd/MM, HH:mm').format(date);
      } catch (_) {}
    }

    // Obtener titulo (Mesas)
    String title = order.tables?.map((t) => t.name).join(', ') ?? 'Sin Mesa';
    if (title.isEmpty && order.originType != null) {
      title = order.originType!;
    }

    final idDisplay = order.orderNumber!;

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
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(20),
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () => _showOrderDetails(context, order),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Text(
                          '#$idDisplay - $title',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Row(
                      children: [
                        Icon(Icons.print_outlined,
                            color: Colors.blue[300], size: 20),
                        const SizedBox(width: 8),
                        Icon(Icons.money, color: Colors.red[300], size: 20),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                _buildInfoRow(
                  'Monto a pagar:',
                  currencyFormat.format(order.total ?? 0),
                  isBold: true,
                ),
                _buildInfoRow('Estado:', statusText, valueColor: statusColor),
                _buildInfoRow('Fecha y hora:', dateText),
              ],
            ),
          ),
        ),
      ),
    );
  }

/*mostrar modal de detalles de pedido*/
  void _showOrderDetails(BuildContext context, OrderModel order) {
    OrderDetailsModal.show(
      context: context,
      order: order,
      availableStatuses: controller.orderDetailStatuses,
      onUpdateStatus: controller.updateDetailsStatus,
      getStatusDescription: controller.getDetailStatusDescription,
    );
  }

  /*build fila de informacion en la tarjeta de pedido*/
  Widget _buildInfoRow(
    String label,
    String value, {
    bool isBold = false,
    Color? valueColor,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.black87)),
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
