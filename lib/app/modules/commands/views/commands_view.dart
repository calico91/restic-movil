import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:restic_movil/app/data/models/order_model.dart';
import 'package:restic_movil/app/data/models/table_model.dart';
import 'package:restic_movil/core/utils/modals/global_order_details_modal.dart';
import '../controllers/commands_controller.dart';

class CommandsView extends GetView<CommandsController> {
  const CommandsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildTabs(),
        Expanded(
          child: Obx(() {
            final ordersList = controller.currentTab.value == 0
                ? controller.orders
                : controller.finalizedOrders;

            return RefreshIndicator(
              onRefresh: () async => controller.currentTab.value == 0
                  ? await controller.loadOrders()
                  : await controller.loadFinalizedOrders(),
              child: ordersList.isEmpty
                  ? ListView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      children: [
                        const SizedBox(height: 50),
                        Center(
                          child: Text(
                            controller.currentTab.value == 0
                                ? 'No hay pedidos nuevos'
                                : 'No hay pedidos finalizados',
                            style: const TextStyle(
                              fontSize: 18,
                              color: Colors.grey,
                            ),
                          ),
                        ),
                      ],
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.only(
                        left: 16,
                        right: 16,
                        top: 16,
                        bottom:
                            100, // Espacio extra para la barra de navegaciÃ³n
                      ),
                      physics: const AlwaysScrollableScrollPhysics(),
                      itemCount: ordersList.length,
                      itemBuilder: (context, index) {
                        final order = ordersList[index];
                        return _buildOrderCard(context, order);
                      },
                    ),
            );
          }),
        ),
      ],
    );
  }

  Widget _buildTabs() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Obx(
        () => Row(
          children: [
            Expanded(
              child: _buildTabButton(
                title: 'Pendientes',
                isSelected: controller.currentTab.value == 0,
                onTap: () => controller.changeTab(0),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _buildTabButton(
                title: 'Historial',
                isSelected: controller.currentTab.value == 1,
                onTap: () => controller.changeTab(1),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTabButton({
    required String title,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return InkWell(
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
  }

  /*build tarjeta de pedido*/
  Widget _buildOrderCard(BuildContext context, OrderModel order) {
    String formattedDate = order.openingDate ?? '';
    try {
      if (order.openingDate != null) {
        final date = DateTime.parse(order.openingDate!);
        formattedDate = DateFormat('dd/MM/yyyy HH:mm').format(date);
      }
      if (order.closingDate != null &&
          (order.status == 'Finalizada' || order.status == 'FINALIZED')) {
        final date = DateTime.parse(order.closingDate!);
        formattedDate = DateFormat('dd/MM/yyyy HH:mm').format(date);
      }
    } catch (_) {}

    // LÃ³gica para tÃ­tulo de la tarjeta
    String title = '';
    final originCode = order.originType?.code;
    final originDesc = order.originType?.description;

    if (originCode == 'TAKE_AWAY' ||
        originCode == 'DELIVERY' ||
        originCode == 'Para llevar' ||
        originCode == 'Domicilio') {
      title =
          order.customer?.fullName ??
          order.customer?.id ??
          (originDesc ?? 'Sin Información');
    } else {
      // Asumimos Salón u otros
      title = _formatTables(order.tables);
      if (title == 'N/A' && originDesc != null) {
        title = originDesc;
      }
    }

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
        child: InkWell(
          onTap: controller.currentTab.value == 0
              ? () => _showOrderDetails(context, order)
              : null,
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
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
                          '#${order.orderNumber ?? "N/A"} - $title',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    _buildStatusChip(order.status),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(Icons.storefront, size: 16, color: Colors.grey),
                    const SizedBox(width: 4),
                    Text('Origen: ${order.originType?.description ?? 'N/A'}'),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Icons.access_time, size: 16, color: Colors.grey),
                    const SizedBox(width: 4),
                    Text('Fecha: $formattedDate'),
                  ],
                ),
                if (order.observations != null &&
                    order.observations!.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(Icons.comment, size: 16, color: Colors.grey),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            'Obs: ${order.observations}',
                            style: const TextStyle(fontStyle: FontStyle.italic),
                          ),
                        ),
                      ],
                    ),
                  ),
                const SizedBox(height: 8),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /*formatear mesas */
  String _formatTables(List<TableModel>? tables) {
    if (tables == null || tables.isEmpty) return 'N/A';
    return tables.map((t) => t.name).join(', ');
  }

  /*construir chip de estado */
  Widget _buildStatusChip(String? status) {
    Color color = Colors.grey;
    String label = status ?? 'UNKNOWN';

    // Obtener descripciÃ³n si estÃ¡ disponible
    if (status != null) {
      label = controller.getStatusDescription(status);
    }
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

    return Chip(
      label: Text(
        label,
        style: const TextStyle(color: Colors.white, fontSize: 12),
      ),
      backgroundColor: color,
      padding: EdgeInsets.zero,
      visualDensity: VisualDensity.compact,
    );
  }

  /*mostrar detalles del pedido */
  void _showOrderDetails(BuildContext context, OrderModel order) {
    GlobalOrderDetailsModal.show(
      context: context,
      order: order,
      availableStatuses: controller.orderDetailStatuses,
      onUpdateStatus: controller.updateDetailsStatus,
      getStatusDescription: controller.getDetailStatusDescription,
    );
  }
}
