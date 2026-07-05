import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:restic_movil/app/data/models/category_model.dart';
import 'package:restic_movil/app/data/models/order_detail_model.dart';
import 'package:restic_movil/app/data/models/order_model.dart';
import 'package:restic_movil/app/data/services/printer_service.dart';
import 'package:restic_movil/app/data/services/storage_service.dart';
import 'package:restic_movil/core/utils/buttons/card_buttons.dart';
import 'package:restic_movil/core/utils/widgets/order_status_chip.dart';
import 'package:restic_movil/core/utils/printers/tickets/58mm/order_ticket_58mm.dart';
import 'package:restic_movil/core/utils/printers/tickets/80mm/order_ticket_80mm.dart';
import 'package:restic_movil/core/utils/printers/tickets/58mm/precount_ticket_58mm.dart';
import 'package:restic_movil/core/utils/printers/tickets/80mm/precount_ticket_80mm.dart';
import 'package:restic_movil/core/utils/snackbars/info_snackbar.dart';
import 'package:restic_movil/core/utils/modals/modal_error.dart';
import 'package:restic_movil/core/utils/formatters/currency_formatter.dart';
import 'package:restic_movil/core/utils/icons/action_icon_button.dart';

class GlobalOrderCard extends StatelessWidget {
  final OrderModel order;
  final VoidCallback? onDetailsPressed;
  final String detailsText;
  final VoidCallback? onActionPressed;
  final String? actionText;
  final VoidCallback? onManageSurchargesPressed;
  final VoidCallback? onPrintCustomAction;
  final String printTooltip;
  final VoidCallback? onCancelPressed;
  final bool showPrintButton;
  final bool showCommandaButton;
  // Categorias con configuracion de impresora para enrutamiento multi-printer
  final List<CategoryModel>? categories;

  const GlobalOrderCard({
    super.key,
    required this.order,
    this.onDetailsPressed,
    this.detailsText = 'Ver Detalles',
    this.onManageSurchargesPressed,
    this.onActionPressed,
    this.actionText,
    this.onPrintCustomAction,
    this.printTooltip = 'Imprimir pedido',
    this.onCancelPressed,
    this.showPrintButton = true,
    this.showCommandaButton = false,
    this.categories,
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

    // Obtener titulo (Origen)
    String title = order.originType?.description ?? 'Sin Origen';

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
                if (onManageSurchargesPressed != null) ...[
                  const SizedBox(width: 4),
                  ActionIconButton(
                    icon: Icons.edit_note,
                    color: Colors.blue,
                    size: 24,
                    tooltip: 'Gestionar cargos',
                    onPressed: onManageSurchargesPressed!,
                    constraints: const BoxConstraints(),
                    padding: EdgeInsets.zero,
                  ),
                ],
                const SizedBox(width: 8),
                if (showPrintButton)
                  Obx(() {
                    final printerService = Get.find<PrinterService>();
                    final isConnected = printerService.isConnected.value ||
                        printerService.isNetworkConnected.value;

                    // Imprime la comanda de cocina
                    void printComanda() {
                      Get.showSnackbar(
                        const InfoSnackbar('Enviando comanda a imprimir...'),
                      );
                      if (onPrintCustomAction != null) {
                        onPrintCustomAction!();
                      } else {
                        final bool is80mm =
                            printerService.printerSize.value == '80mm';
                        final List<OrderDetailModel>? details = order.details;
                        final List<CategoryModel>? cats = categories;
                        if (cats != null &&
                            cats.isNotEmpty &&
                            details != null &&
                            details.isNotEmpty) {
                          printerService.printComandaMultiPrinterFromDetails(
                            order: order,
                            details: details,
                            categories: cats,
                            ticketBuilder: (o, filteredDetails) => is80mm
                                ? OrderTicket80mm(
                                    order: o,
                                    filteredDetails: filteredDetails,
                                  )
                                : OrderTicket58mm(
                                    order: o,
                                    filteredDetails: filteredDetails,
                                  ),
                          );
                        } else {
                          printerService.printTicket(
                            is80mm
                                ? OrderTicket80mm(order: order)
                                : OrderTicket58mm(order: order),
                          );
                        }
                      }
                    }

                    // Imprime la precuenta con el porcentaje de propina guardado
                    Future<void> printPrecount() async {
                      final storageService = Get.find<StorageService>();
                      final tipStr =
                          await storageService.getDefaultTipPercentage() ?? '0';
                      final double tip = double.tryParse(tipStr) ?? 0.0;
                      final bool is80mm =
                          printerService.printerSize.value == '80mm';
                      printerService.printTicket(
                        is80mm
                            ? PrecountTicket80mm(
                                order: order,
                                tipPercentage: tip,
                              )
                            : PrecountTicket58mm(
                                order: order,
                                tipPercentage: tip,
                              ),
                      );
                    }

                    return Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Botón de imprimir comanda de cocina (solo si showCommandaButton)
                        if (showCommandaButton) ...[
                          ActionIconButton(
                            icon: Icons.kitchen,
                            color: isConnected ? Colors.green : Colors.red,
                            size: 24,
                            tooltip: isConnected
                                ? 'Imprimir comanda'
                                : 'Impresora no conectada',
                            onPressed: isConnected
                                ? printComanda
                                : () => Get.dialog(const ModalError(message: 'Impresora no conectada',
                                      ),
                                    ),
                            constraints: const BoxConstraints(),
                            padding: EdgeInsets.zero,
                          ),
                          const SizedBox(width: 4),
                        ],
                        // Botón de imprimir (precuenta o factura según contexto)
                        ActionIconButton(
                          icon: Icons.receipt_long,
                          color: isConnected ? Colors.orange : Colors.red,
                          size: 24,
                          tooltip: isConnected
                              ? printTooltip
                              : 'Impresora no conectada',
                          onPressed: isConnected
                              ? () {
                                  if (onPrintCustomAction != null) {
                                    onPrintCustomAction!();
                                  } else {
                                    Get.showSnackbar(
                                      const InfoSnackbar(
                                        'Enviando precuenta a imprimir...',
                                      ),
                                    );
                                    printPrecount();
                                  }
                                }
                              : () => Get.dialog(const ModalError(message: 'Impresora no conectada',
                                    ),
                                  ),
                          constraints: const BoxConstraints(),
                          padding: EdgeInsets.zero,
                        ),
                      ],
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
            _buildInfoRow('Cliente:', order.customer?.fullName ?? 'Sin información'),
            _buildInfoRow('Creado por:', order.createdBy?.fullName ?? 'Sin información'),
            if (order.tables != null && order.tables!.isNotEmpty)
              _buildInfoRow('Mesa:', order.tables!.map((t) => t.name).join(', ')),
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
