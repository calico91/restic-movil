import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:restic_movil/app/data/models/order_detail_model.dart';
import 'package:restic_movil/app/data/models/order_model.dart';

class OrderDetailsModal {
  static void show({
    required BuildContext context,
    required OrderModel order,
    required List<Map<String, dynamic>> availableStatuses,
    required Function(List<String> detailIds, String status, String tableNames)
        onUpdateStatus,
    required String Function(String) getStatusDescription,
  }) {
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
                    return _buildDetailItem(
                        item, selectedIds, getStatusDescription);
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
                              availableStatuses,
                              onUpdateStatus,
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

  static void _showStatusSelection(
    BuildContext context,
    List<String> detailIds,
    OrderModel order,
    List<Map<String, dynamic>> availableStatuses,
    Function(List<String>, String, String) onUpdateStatus,
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
            ...availableStatuses.map((status) {
              return ListTile(
                title: Text(status['description'] ?? status['name']),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {
                  final String orderIdentifier = order.orderNumber != null
                      ? '${order.orderNumber}'
                      : (order.id != null ? order.id!.substring(0, 8) : 'N/A');

                  onUpdateStatus(detailIds, status['name'], orderIdentifier);
                },
              );
            }),
          ],
        ),
      ),
    );
  }

  static Widget _buildDetailItem(
    OrderDetailModel item,
    RxSet<String> selectedIds,
    String Function(String) getStatusDescription,
  ) {
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
                          'Estado: ${getStatusDescription(item.status ?? "N/A")}',
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
