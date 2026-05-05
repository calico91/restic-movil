import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:restic_movil/app/data/models/order_item_model.dart';
import 'package:restic_movil/app/data/models/order_model.dart';
import 'package:restic_movil/app/data/services/printer_service.dart';
import 'package:restic_movil/core/utils/modals/modal_info.dart';
import 'package:restic_movil/core/utils/printers/tickets/58mm/added_items_ticket_58mm.dart';
import 'package:restic_movil/core/utils/printers/tickets/58mm/delivery_ticket_58mm.dart';
import 'package:restic_movil/core/utils/printers/tickets/58mm/order_ticket_58mm.dart';
import 'package:restic_movil/core/utils/printers/tickets/80mm/added_items_ticket_80mm.dart';
import 'package:restic_movil/core/utils/printers/tickets/80mm/delivery_ticket_80mm.dart';
import 'package:restic_movil/core/utils/printers/tickets/80mm/order_ticket_80mm.dart';
import 'package:restic_movil/core/utils/snackbars/info_snackbar.dart';

// Modal reutilizable para confirmar creacion o actualizacion de pedidos con opcion de impresion.
// Si se proveen [addedItems], imprime solo esos productos (ticket adicional);
// si es null, imprime la orden completa.
class OrderSuccessModal extends StatelessWidget {
  final String title;
  final String message;
  final OrderModel order;
  final List<OrderItemModel>? addedItems;
  final VoidCallback? onClose;
  final String buttonText;

  const OrderSuccessModal({
    super.key,
    required this.title,
    required this.message,
    required this.order,
    this.addedItems,
    this.onClose,
    this.buttonText = 'Cerrar',
  });

  @override
  Widget build(BuildContext context) {
    final PrinterService printerService = Get.find<PrinterService>();
    final bool isConnected =
        printerService.isConnected.value || printerService.isNetworkConnected.value;

    return ModalInfo(
      title: title,
      message: message,
      icon: Icons.check_circle,
      buttonText: buttonText,
      onClose: onClose,
      secondaryButtonText: 'Imprimir Orden',
      onSecondaryAction: isConnected
          ? () {
              Get.showSnackbar(const InfoSnackbar('Enviando a imprimir...'));
              final bool is80mm = printerService.printerSize.value == '80mm';

              if (addedItems != null) {
                // Imprimir solo los productos recien agregados
                printerService.printTicket(
                  is80mm
                      ? AddedItemsTicket80mm(order: order, items: addedItems!)
                      : AddedItemsTicket58mm(order: order, items: addedItems!),
                );
              } else {
                // Imprimir la orden completa
                if (order.originType?.code == 'DELIVERY') {
                  printerService.printTicket(
                    is80mm
                        ? DeliveryTicket80mm(order: order)
                        : DeliveryTicket58mm(order: order),
                  );
                } else {
                  printerService.printTicket(
                    is80mm
                        ? OrderTicket80mm(order: order)
                        : OrderTicket58mm(order: order),
                  );
                }
              }

              onClose?.call();
            }
          : null,
    );
  }
}
