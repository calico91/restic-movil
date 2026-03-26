import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:restic_movil/app/data/models/order_model.dart';
import 'package:restic_movil/app/data/services/printer_service.dart';
import 'package:restic_movil/core/utils/buttons/card_buttons.dart';
import 'package:restic_movil/core/utils/widgets/order_status_chip.dart';
import 'package:restic_movil/core/utils/printers/tickets/order_ticket.dart';
import 'package:restic_movil/core/utils/snackbars/info_snackbar.dart';
import 'package:restic_movil/core/utils/snackbars/error_snackbar.dart';
import 'package:restic_movil/core/utils/formatters/currency_formatter.dart';
import 'package:restic_movil/core/utils/icons/action_icon_button.dart';

class GlobalOrderCard extends StatelessWidget {
  final OrderModel order;
  final VoidCallback? onDetailsPressed;
  final String detailsText;
  final VoidCallback? onActionPressed;
  final String? actionText;
  final VoidCallback? onPrintCustomAction;
  final String printTooltip;
  final VoidCallback? onCancelPressed;

  const GlobalOrderCard({
    super.key,
    required this.order,
    this.onDetailsPressed,
    this.detailsText = 'Ver Detalles',
    this.onActionPressed,
    this.actionText,
    this.onPrintCustomAction,
    this.printTooltip = 'Imprimir pedido',
    this.onCancelPressed,
  });

  @override
  Widget build(BuildContext context) {
    String statusText = order.status ?? '';

    // Formatear fecha
    String dateText = '';

    // Si tiene fecha de cierre mostrarla tambien o en lugar de
    if (order.closingDate != null &&
        (statusText == 'Finalizada' || statusText == 'FINALIZED')) {
      try {
        final date = DateTime.parse(order.closingDate!);
        dateText = DateFormat('dd/MM, HH:mm').format(date);
      } catch (_) {}
    } else if (order.openingDate != null) {
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
            order.originType == 'Para llevar' ||
            order.originType == 'TAKE_AWAY' ||
            order.originType == 'DELIVERY')) {
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
                Obx(() {
                  final printerService = Get.find<PrinterService>();
                  final isConnected = printerService.isConnected.value;
                  return ActionIconButton(
                    icon: Icons.print,
                    color: isConnected ? Colors.green : Colors.red,
                    size: 24,
                    tooltip: isConnected
                        ? printTooltip
                        : 'Impresora no conectada',
                    onPressed: isConnected
                        ? () {
                            Get.showSnackbar(
                              const InfoSnackbar('Enviando a imprimir...'),
                            );
                            if (onPrintCustomAction != null) {
                              onPrintCustomAction!();
                            } else {
                              printerService.printTicket(
                                OrderTicket(order: order),
                              );
                            }
                          }
                        : () {
                            Get.showSnackbar(
                              const ErrorSnackbar('Impresora no conectada'),
                            );
                          },
                    constraints: const BoxConstraints(),
                    padding: EdgeInsets.zero,
                  );
                }),
                if (onCancelPressed != null) ...[
                  const SizedBox(width: 4),
                  ActionIconButton(
                    icon: Icons.block,
                    color: Colors.red,
                    size: 24,
                    tooltip: 'Anular orden',
                    onPressed: onCancelPressed!,
                    constraints: const BoxConstraints(),
                    padding: EdgeInsets.zero,
                  ),
                ],
              ],
            ),
            const SizedBox(height: 10),
            _buildInfoRow(
              'Monto a pagar:',
              CurrencyFormatter.toCurrency(order.total ?? 0),
              isBold: true,
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Estado:',
                    style: TextStyle(color: Colors.black87),
                  ),
                  OrderStatusChip(status: statusText, label: statusText),
                ],
              ),
            ),
            _buildInfoRow('Origen:', order.originType ?? 'N/A'),
            _buildInfoRow('Fecha y hora:', dateText),
            const SizedBox(height: 15),
            Row(
              children: [
                if (onDetailsPressed != null) ...[
                  Expanded(
                    child: CardPrimaryButton(
                      text: detailsText,
                      onPressed: onDetailsPressed!,
                    ),
                  ),
                ],
                if (onDetailsPressed != null && onActionPressed != null)
                  const SizedBox(width: 10),
                if (onActionPressed != null && actionText != null) ...[
                  Expanded(
                    child: CardOutlinedButton(
                      text: actionText!,
                      onPressed: onActionPressed!,
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

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
