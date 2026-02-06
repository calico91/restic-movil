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
        const SizedBox(height: 10),
        _buildTabs(),
        const SizedBox(height: 10),
        Obx(
          () => controller.currentTab.value == 0
              ? _buildCreateOrderButton()
              : const SizedBox.shrink(),
        ),
        const SizedBox(height: 20),
        _buildOrdersList(),
      ],
    );
  }

  /*build pestañas de filtros*/
  Widget _buildTabs() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Obx(
        () => Row(
          children: [
            Expanded(
              child: _buildTabButton(
                title: 'Activos',
                isSelected: controller.currentTab.value == 0,
                onTap: () => controller.changeTab(0),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _buildTabButton(
                title: 'Finalizados',
                isSelected: controller.currentTab.value == 1,
                onTap: () => controller.changeTab(1),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /*build boton de pestaña*/
  Widget _buildTabButton({
    required String title,
    required bool isSelected,
    required VoidCallback onTap,
  }) => InkWell(
    onTap: onTap,
    borderRadius: BorderRadius.circular(30),
    child: Container(
      padding: const EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(
        color: isSelected ? Colors.blue[900] : Colors.white,
        borderRadius: BorderRadius.circular(30),
        border: Border.all(
          color: isSelected ? Colors.blue[900]! : Colors.grey[300]!,
        ),
        boxShadow: isSelected
            ? [
                BoxShadow(
                  color: Colors.blue.withValues(alpha: 0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ]
            : null,
      ),
      alignment: Alignment.center,
      child: Text(
        title,
        style: TextStyle(
          color: isSelected ? Colors.white : Colors.grey[600],
          fontWeight: FontWeight.bold,
        ),
      ),
    ),
  );

  /*build barra de busqueda*/
  Widget _buildSearchBar() => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 15),
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
          hintText: 'mesa o nombre del cliente',
          prefixIcon: Icon(Icons.search, color: Colors.blue),
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(vertical: 15),
        ),
      ),
    ),
  );

  /*build boton crear pedido*/
  Widget _buildCreateOrderButton() => Padding(
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

  /*build lista de pedidos*/
  Widget _buildOrdersList() => Expanded(
    child: Obx(() {
      final ordersList = controller.currentTab.value == 0
          ? controller.orders
          : controller.finalizedOrders;

      return RefreshIndicator(
        onRefresh: () async => controller.currentTab.value == 0
            ? await controller.loadOrders(withOverlay: false)
            : await controller.loadFinalizedOrders(withOverlay: false),
        child: ListView.builder(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.only(left: 16, right: 16, bottom: 80),
          itemCount: ordersList.length,
          itemBuilder: (context, index) {
            final order = ordersList[index];
            return _buildOrderCard(context, order);
          },
        ),
      );
    }),
  );

  /*build tarjeta de pedido*/
  Widget _buildOrderCard(BuildContext context, OrderModel order) {
    Color statusColor;
    String statusText = order.status ?? '';

    switch (statusText) {
      case 'Abierta':
        statusColor = Colors.orange;
        break;
      case 'Anulada':
        statusColor = Colors.blue;
        break;
      case 'Pagada':
        statusColor = Colors.black87;
        break;
      case 'Finalizada':
        statusColor = Colors.green;
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

    // Si tiene fecha de cierre mostrarla tambien o en lugar de
    if (order.closingDate != null && (statusText == 'Finalizado')) {
      try {
        final date = DateTime.parse(order.closingDate!);
        dateText = DateFormat('dd/MM, HH:mm').format(date);
      } catch (_) {}
    }
    if (order.openingDate != null) {
      try {
        final date = DateTime.parse(order.openingDate!);
        dateText = DateFormat('dd/MM, HH:mm').format(date);
      } catch (_) {}
    }

    // Obtener titulo (Mesas o Cliente)
    String title = order.tables?.map((t) => t.name).join(', ') ?? '';

    // Si no hay mesas, intentamos usar el cliente si es Take Away o Delivery
    if (title.isEmpty &&
        (order.originType == 'Domicilio' ||
            order.originType == 'Para llevar')) {
      if (order.customerName != null) {
        title = order.customerName!;
      } else if (order.originType != null) {
        title = order.originType!;
      } else {
        title = 'Sin información';
      }
    } else if (title.isEmpty) {
      // Fallback a origin type
      title = order.originType ?? 'Sin Mesa';
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
                    Icon(
                      Icons.print_outlined,
                      color: Colors.blue[300],
                      size: 20,
                    ),
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
            _buildInfoRow('Origen:', order.originType ?? 'N/A'),
            _buildInfoRow('Fecha y hora:', dateText),
            const SizedBox(height: 15),
            Row(
              children: [
                if (controller.currentTab.value == 0)
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => _showOrderDetails(context, order),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue[900],
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 10),
                      ),
                      child: const Text('Ver Detalles'),
                    ),
                  ),
                const SizedBox(width: 10),
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => controller.startAddProducts(order),
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: Colors.blue[900]!),
                      foregroundColor: Colors.blue[900],
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 10),
                    ),
                    child: const Text('Agregar'),
                  ),
                ),
              ],
            ),
          ],
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
  }) => Padding(
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
