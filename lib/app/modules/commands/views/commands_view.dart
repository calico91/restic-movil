import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:restic_movil/app/data/models/order_detail_model.dart';
import 'package:restic_movil/app/data/models/order_model.dart';
import 'package:restic_movil/app/data/models/table_model.dart';
import '../controllers/commands_controller.dart';

class CommandsView extends GetView<CommandsController> {
  const CommandsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      return RefreshIndicator(
        onRefresh: () async => await controller.loadOrders(),
        child: controller.orders.isEmpty
            ? ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                children: const [
                  SizedBox(height: 50),
                  Center(
                    child: Text(
                      'No hay pedidos nuevos',
                      style: TextStyle(fontSize: 18, color: Colors.grey),
                    ),
                  ),
                ],
              )
            : ListView.builder(
                padding: const EdgeInsets.all(16),
                physics: const AlwaysScrollableScrollPhysics(),
                itemCount: controller.orders.length,
                itemBuilder: (context, index) {
                  final order = controller.orders[index];
                  return _buildOrderCard(context, order);
                },
              ),
      );
    });
  }

  /*build tarjeta de pedido*/
  Widget _buildOrderCard(BuildContext context, OrderModel order) {
    String formattedDate = order.openingDate ?? '';
    try {
      if (order.openingDate != null) {
        final date = DateTime.parse(order.openingDate!);
        formattedDate = DateFormat('dd/MM/yyyy HH:mm').format(date);
      }
    } catch (_) {}

    return Card(
      elevation: 4,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () => _showOrderDetails(context, order),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      'Mesa: ${_formatTables(order.tables)}',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  _buildStatusChip(order.status),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(Icons.storefront, size: 16, color: Colors.grey),
                  const SizedBox(width: 4),
                  Text('Origen: ${order.originType ?? "N/A"}'),
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
              if (order.observations != null && order.observations!.isNotEmpty)
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
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () => _showOrderStatusSelection(context, order),
                  icon: const Icon(Icons.edit, size: 16),
                  label: const Text('Cambiar Estado de Orden'),
                  style: OutlinedButton.styleFrom(
                    visualDensity: VisualDensity.compact,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /*mostrar seleccion de estado de orden */
  void _showOrderStatusSelection(BuildContext context, OrderModel order) {
    if (order.id == null) return;

    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(20),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Cambiar Estado de Orden',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            ...controller.orderStatuses.map((status) {
              return ListTile(
                title: Text(status['description'] ?? status['name']),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {
                  final tableNames =
                      order.tables?.map((t) => t.name).join(', ') ?? '';
                  controller.updateOrderStatus(
                    order.id!,
                    status['name'],
                    tableNames,
                  );
                },
              );
            }),
          ],
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

    // Obtener descripción si está disponible
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
    final RxSet<String> selectedIds = <String>{}.obs;

    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Detalles del Pedido',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Get.back(),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
              ),
              const Divider(),
              // Select All Row
              Row(
                children: [
                  Obx(() {
                    final isAllSelected =
                        order.details != null &&
                        order.details!.isNotEmpty &&
                        selectedIds.length == order.details!.length;
                    return Checkbox(
                      value: isAllSelected,
                      onChanged: (val) {
                        if (val == true) {
                          selectedIds.addAll(
                            order.details?.map((e) => e.id!).toList() ?? [],
                          );
                        } else {
                          selectedIds.clear();
                        }
                      },
                    );
                  }),
                  const Text('Seleccionar Todos'),
                ],
              ),
              const SizedBox(height: 8),
              ConstrainedBox(
                constraints: BoxConstraints(maxHeight: Get.height * 0.5),
                child: ListView.separated(
                  shrinkWrap: true,
                  itemCount: order.details?.length ?? 0,
                  separatorBuilder: (_, _) => const Divider(height: 1),
                  itemBuilder: (context, index) {
                    final item = order.details![index];
                    return _buildDetailItem(item, selectedIds);
                  },
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: Obx(
                  () => ElevatedButton.icon(
                    onPressed: selectedIds.isEmpty
                        ? null
                        : () => _showStatusSelection(
                            context,
                            selectedIds.toList(),
                            order,
                          ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue[900],
                      foregroundColor: Colors.white,
                      disabledBackgroundColor: Colors.grey[300],
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    icon: const Icon(Icons.edit_note),
                    label: const Text(
                      'Cambiar Estado',
                      style: TextStyle(fontSize: 16),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /*mostrar selección de estado */
  void _showStatusSelection(
    BuildContext context,
    List<String> detailIds,
    OrderModel order,
  ) {
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(20),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Seleccionar Nuevo Estado',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            ...controller.orderDetailStatuses.map((status) {
              return ListTile(
                title: Text(status['description'] ?? status['name']),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {
                  final tableNames =
                      order.tables?.map((t) => t.name).join(', ') ?? '';
                  controller.updateDetailsStatus(
                    detailIds,
                    status['name'],
                    tableNames,
                  );
                },
              );
            }),
          ],
        ),
      ),
    );
  }

  /*construir item de detalle con checkbox */
  Widget _buildDetailItem(OrderDetailModel item, RxSet<String> selectedIds) {
    if (item.id == null) return const SizedBox.shrink();

    return Obx(
      () => Padding(
        padding: const EdgeInsets.symmetric(vertical: 4.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Checkbox(
              value: selectedIds.contains(item.id),
              onChanged: (val) {
                if (val == true) {
                  selectedIds.add(item.id!);
                } else {
                  selectedIds.remove(item.id);
                }
              },
            ),
            Expanded(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CircleAvatar(
                    backgroundColor: Colors.blue[100],
                    radius: 18,
                    child: Text(
                      '${item.quantity ?? 0}',
                      style: TextStyle(
                        color: Colors.blue[900],
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.productName ?? 'Producto desconocido',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                          ),
                        ),
                        Text(
                          'Estado: ${controller.getDetailStatusDescription(item.status ?? "N/A")}',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 12,
                          ),
                        ),
                        if (item.observations != null &&
                            item.observations!.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(top: 2.0),
                            child: Text(
                              'Nota: ${item.observations}',
                              style: const TextStyle(
                                color: Colors.deepOrange,
                                fontStyle: FontStyle.italic,
                                fontSize: 12,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
