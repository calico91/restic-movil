import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:restic_movil/app/data/models/order_detail_model.dart';
import 'package:restic_movil/app/data/models/order_model.dart';
import 'package:restic_movil/core/utils/formatters/currency_formatter.dart';

class GlobalOrderDetailsModal extends StatelessWidget {
  final OrderModel order;
  final bool isReadOnly;
  final List<Map<String, dynamic>>? availableStatuses;
  final Function(
    List<Map<String, dynamic>> items,
    String status,
    String orderIdentifier,
  )?
  onUpdateStatus;
  final String Function(String)? getStatusDescription;

  const GlobalOrderDetailsModal({
    super.key,
    required this.order,
    this.isReadOnly = false,
    this.availableStatuses,
    this.onUpdateStatus,
    this.getStatusDescription,
  });

  static void show({
    required BuildContext context,
    required OrderModel order,
    bool isReadOnly = false,
    List<Map<String, dynamic>>? availableStatuses,
    Function(List<Map<String, dynamic>>, String, String)? onUpdateStatus,
    String Function(String)? getStatusDescription,
  }) {
    Get.dialog(
      GlobalOrderDetailsModal(
        order: order,
        isReadOnly: isReadOnly,
        availableStatuses: availableStatuses,
        onUpdateStatus: onUpdateStatus,
        getStatusDescription: getStatusDescription,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final RxSet<String> selectedIds = <String>{}.obs;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    'Detalles del Pedido #${order.orderNumber}',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Get.back(),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  color: Colors.red[800],
                ),
              ],
            ),
            const Divider(),
            if (!isReadOnly)
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
            if (!isReadOnly) const SizedBox(height: 8),

            // Header for Cash Register (readOnly)
            if (isReadOnly) ...[
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
            ],

            ConstrainedBox(
              constraints: BoxConstraints(maxHeight: Get.height * 0.5),
              child: ListView.separated(
                shrinkWrap: true,
                itemCount: order.details?.length ?? 0,
                separatorBuilder: (_, __) => const Divider(height: 1),
                itemBuilder: (context, index) {
                  final item = order.details![index];
                  if (isReadOnly) {
                    return _buildReadOnlyItem(item);
                  } else {
                    return _buildDetailItem(item, selectedIds);
                  }
                },
              ),
            ),

            if (isReadOnly) const Divider(),
            if (isReadOnly && (order.surcharges?.isNotEmpty ?? false)) ...[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Subtotal:',
                    style: TextStyle(fontSize: 14),
                  ),
                  Text(
                    CurrencyFormatter.toCurrency(order.subtotal ?? (order.total ?? 0)),
                    style: const TextStyle(fontSize: 14),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              ...order.surcharges!.map((surcharge) => Padding(
                    padding: const EdgeInsets.only(bottom: 4.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          surcharge.description,
                          style: const TextStyle(fontSize: 14),
                        ),
                        Text(
                          CurrencyFormatter.toCurrency(surcharge.amount),
                          style: const TextStyle(fontSize: 14),
                        ),
                      ],
                    ),
                  )),
              const Divider(),
            ],
            if (isReadOnly)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Total:',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  Text(
                    CurrencyFormatter.toCurrency(order.total ?? 0),
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Colors.green[700],
                    ),
                  ),
                ],
              ),

            if (!isReadOnly &&
                availableStatuses != null &&
                onUpdateStatus != null) ...[
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
                          ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF0D47A1),
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
            ] else if (isReadOnly) ...[
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Get.back(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0D47A1),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Text('Cerrar'),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildReadOnlyItem(OrderDetailModel item) {
    final statusUpper = item.status?.toUpperCase() ?? '';
    final isAnulado = statusUpper == 'ANULADO' || statusUpper == 'CANCELED';

    final textColor = isAnulado ? Colors.grey[400] : null;
    final valueColor = isAnulado ? Colors.grey[400] : Colors.grey;
    final subtotal = isAnulado ? 0.0 : (item.subtotal ?? 0.0);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 4,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.sizeLabel != null
                      ? '${item.productName ?? '-'} - ${item.sizeLabel}'
                      : (item.productName ?? '-'),
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: textColor,
                    decoration: isAnulado ? TextDecoration.lineThrough : null,
                  ),
                ),
                if (item.comboSelections != null &&
                    item.comboSelections!.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 4.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: item.comboSelections!.map((selection) {
                        final quantityText =
                            (selection.quantity != null &&
                                selection.quantity! > 1)
                            ? ' (${selection.quantity})'
                            : '';
                        return Text(
                          '• ${selection.selectedProductName ?? 'Opción'} (${selection.comboGroupName ?? ''})$quantityText',
                          style: TextStyle(
                            color: isAnulado
                                ? Colors.grey[400]
                                : Colors.grey[700],
                            fontSize: 11,
                            decoration: isAnulado
                                ? TextDecoration.lineThrough
                                : null,
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                if (item.observations != null && item.observations!.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 2.0),
                    child: Text(
                      'Nota: ${item.observations}',
                      style: TextStyle(
                        color: isAnulado ? Colors.grey[400] : Colors.deepOrange,
                        fontStyle: FontStyle.italic,
                        fontSize: 11,
                        decoration: isAnulado
                            ? TextDecoration.lineThrough
                            : null,
                      ),
                    ),
                  ),
                if (isAnulado)
                  Padding(
                    padding: const EdgeInsets.only(top: 2.0),
                    child: Text(
                      'ANULADO',
                      style: TextStyle(
                        color: Colors.grey[500],
                        fontWeight: FontWeight.bold,
                        fontSize: 10,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          SizedBox(
            width: 36,
            child: Text(
              'x${item.quantity ?? 0}',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13,
                color: valueColor,
                decoration: isAnulado ? TextDecoration.lineThrough : null,
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              CurrencyFormatter.toCurrency(subtotal),
              textAlign: TextAlign.right,
              style: TextStyle(fontSize: 13, color: textColor),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailItem(OrderDetailModel item, RxSet<String> selectedIds) {
    if (item.id == null) return const SizedBox.shrink();

    Color statusColor;
    Color quantityBgColor;
    Color quantityTextColor;

    switch (item.status) {
      case 'Pendiente':
        statusColor = Colors.blue;
        quantityBgColor = Colors.blue[100]!;
        quantityTextColor = Colors.blue[900]!;
        break;
      case 'En preparación':
        statusColor = Colors.orange;
        quantityBgColor = Colors.orange[100]!;
        quantityTextColor = Colors.orange[900]!;
        break;
      case 'Preparado':
        statusColor = Colors.red;
        quantityBgColor = Colors.red[100]!;
        quantityTextColor = Colors.red[900]!;
        break;
      case 'Servido':
        statusColor = Colors.green;
        quantityBgColor = Colors.green[100]!;
        quantityTextColor = Colors.green[900]!;
        break;
      case 'Anulado':
      case 'CANCELED':
      case 'ANULADO':
        statusColor = Colors.grey;
        quantityBgColor = Colors.grey[300]!;
        quantityTextColor = Colors.grey[800]!;
        break;
      default:
        statusColor = Colors.grey;
        quantityBgColor = Colors.grey[200]!;
        quantityTextColor = Colors.black87;
    }

    String statusText = item.status ?? 'N/A';
    if (getStatusDescription != null) {
      statusText = getStatusDescription!(statusText);
    }

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
                    backgroundColor: quantityBgColor,
                    radius: 18,
                    child: Text(
                      '${item.quantity ?? 0}',
                      style: TextStyle(
                        color: quantityTextColor,
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
                          item.sizeLabel != null
                              ? '${item.productName ?? 'Producto desconocido'} - ${item.sizeLabel}'
                              : (item.productName ?? 'Producto desconocido'),
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                          ),
                        ),
                        Text(
                          'Estado: $statusText',
                          style: TextStyle(
                            color: statusColor,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        if (item.comboSelections != null &&
                            item.comboSelections!.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(top: 4.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: item.comboSelections!.map((selection) {
                                final quantityText =
                                    (selection.quantity != null &&
                                        selection.quantity! > 1)
                                    ? ' (${selection.quantity})'
                                    : '';
                                return Text(
                                  '• ${selection.selectedProductName ?? 'Opción'} (${selection.comboGroupName ?? ''})$quantityText',
                                  style: TextStyle(
                                    color: Colors.grey[700],
                                    fontSize: 12,
                                  ),
                                );
                              }).toList(),
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

  void _showStatusSelection(BuildContext context, List<String> detailIds) {
    if (availableStatuses == null || onUpdateStatus == null) return;

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
            ...availableStatuses!.map((status) {
              return ListTile(
                title: Text(status['description'] ?? status['name']),
                trailing: const Icon(Icons.chevron_right),
                onTap: () async {
                  final String orderIdentifier = order.orderNumber != null
                      ? '${order.orderNumber}'
                      : (order.id != null ? order.id!.substring(0, 8) : 'N/A');

                  // Si el estado es CANCELED (Anulado), verificar cantidades
                  if (status['name'] == 'CANCELED') {
                    final selectedDetails =
                        order.details
                            ?.where((d) => detailIds.contains(d.id))
                            .toList() ??
                        [];

                    // Verificar si alguno tiene cantidad > 1
                    final hasMultiQuantity = selectedDetails.any(
                      (d) => (d.quantity ?? 0) > 1,
                    );

                    if (hasMultiQuantity) {
                      Get.back(); // Cerrar bottom sheet primero
                      final result = await _showQuantitySelection(
                        context,
                        selectedDetails,
                      );

                      if (result != null) {
                        onUpdateStatus!(
                          result,
                          status['name'],
                          orderIdentifier,
                        );
                      }
                      return;
                    }
                  }

                  final items =
                      order.details
                          ?.where((d) => detailIds.contains(d.id))
                          .map(
                            (d) => {
                              'detailId': d.id,
                              'quantity': d.quantity ?? 1,
                            },
                          )
                          .toList() ??
                      [];

                  onUpdateStatus!(items, status['name'], orderIdentifier);
                },
              );
            }),
          ],
        ),
      ),
    );
  }

  Future<List<Map<String, dynamic>>?> _showQuantitySelection(
    BuildContext context,
    List<OrderDetailModel> details,
  ) async {
    final quantities = <String, int>{};
    for (var d in details) {
      quantities[d.id!] = d.quantity ?? 1;
    }

    return await Get.dialog<List<Map<String, dynamic>>>(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          'Confirmar Cantidades',
          style: TextStyle(color: Color(0xFF0D47A1)),
        ),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: details.length,
            itemBuilder: (context, index) {
              final item = details[index];
              final maxQty = item.quantity ?? 1;

              return StatefulBuilder(
                builder: (context, setState) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            item.sizeLabel != null
                                ? '${item.productName ?? ''} - ${item.sizeLabel}'
                                : (item.productName ?? ''),
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(fontWeight: FontWeight.w500),
                          ),
                        ),
                        if (maxQty > 1)
                          Row(
                            children: [
                              IconButton(
                                icon: const Icon(Icons.remove_circle_outline),
                                color: Colors.red,
                                onPressed: quantities[item.id!]! > 1
                                    ? () {
                                        setState(() {
                                          quantities[item.id!] =
                                              quantities[item.id!]! - 1;
                                        });
                                      }
                                    : null,
                              ),
                              Text(
                                '${quantities[item.id!]}',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              IconButton(
                                icon: const Icon(Icons.add_circle_outline),
                                color: Colors.green,
                                onPressed: quantities[item.id!]! < maxQty
                                    ? () {
                                        setState(() {
                                          quantities[item.id!] =
                                              quantities[item.id!]! + 1;
                                        });
                                      }
                                    : null,
                              ),
                            ],
                          )
                        else
                          const Padding(
                            padding: EdgeInsets.symmetric(horizontal: 16.0),
                            child: Text('1'),
                          ),
                      ],
                    ),
                  );
                },
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancelar', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () {
              final result = details.map((d) {
                return {'detailId': d.id, 'quantity': quantities[d.id!]};
              }).toList();
              Get.back(result: result);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF0D47A1),
              foregroundColor: Colors.white,
            ),
            child: const Text('Confirmar'),
          ),
        ],
      ),
    );
  }
}
