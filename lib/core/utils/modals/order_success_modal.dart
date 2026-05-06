import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:restic_movil/app/data/models/category_model.dart';
import 'package:restic_movil/app/data/models/order_combo_selection_model.dart';
import 'package:restic_movil/app/data/models/order_detail_model.dart';
import 'package:restic_movil/app/data/models/order_item_model.dart';
import 'package:restic_movil/app/data/models/order_model.dart';
import 'package:restic_movil/app/data/services/printer_service.dart';
import 'package:restic_movil/core/utils/modals/modal_info.dart';
import 'package:restic_movil/core/utils/printers/tickets/58mm/added_items_ticket_58mm.dart';
import 'package:restic_movil/core/utils/printers/tickets/58mm/order_ticket_58mm.dart';
import 'package:restic_movil/core/utils/printers/tickets/80mm/added_items_ticket_80mm.dart';
import 'package:restic_movil/core/utils/printers/tickets/80mm/order_ticket_80mm.dart';
import 'package:restic_movil/core/utils/snackbars/info_snackbar.dart';

// Modal reutilizable para confirmar creacion o actualizacion de pedidos con opcion de impresion.
// Si se proveen [addedItems], imprime solo esos productos (ticket adicional);
// si es null, imprime la orden completa.
// Si se proveen [categories] y [sourceItems], se usa enrutamiento multi-impresora por categoria.
class OrderSuccessModal extends StatelessWidget {
  final String title;
  final String message;
  final OrderModel order;
  final List<OrderItemModel>? addedItems;
  // Items fuente para impresion (nueva orden); requerido si categories != null y addedItems == null
  final List<OrderItemModel>? sourceItems;
  // Categorias con configuracion de impresora para enrutamiento multi-printer
  final List<CategoryModel>? categories;
  final VoidCallback? onClose;
  final String buttonText;

  const OrderSuccessModal({
    super.key,
    required this.title,
    required this.message,
    required this.order,
    this.addedItems,
    this.sourceItems,
    this.categories,
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
              // Items a imprimir: addedItems para adicionales, sourceItems para nueva orden
              final List<OrderItemModel>? itemsToDispatch = addedItems ?? sourceItems;
              final bool hasMultiPrinter =
                  categories != null && categories!.isNotEmpty && itemsToDispatch != null;

              if (addedItems != null) {
                // Imprimir solo los productos recien agregados
                if (hasMultiPrinter) {
                  printerService.printComandaMultiPrinter(
                    order: order,
                    sourceItems: addedItems!,
                    categories: categories!,
                    ticketBuilder: (o, items) => is80mm
                        ? AddedItemsTicket80mm(order: o, items: items)
                        : AddedItemsTicket58mm(order: o, items: items),
                  );
                } else {
                  printerService.printTicket(
                    is80mm
                        ? AddedItemsTicket80mm(order: order, items: addedItems!)
                        : AddedItemsTicket58mm(order: order, items: addedItems!),
                  );
                }
              } else {
                // Orden completa (salon / take-away / domicilio)
                if (hasMultiPrinter) {
                  printerService.printComandaMultiPrinter(
                    order: order,
                    sourceItems: sourceItems!,
                    categories: categories!,
                    ticketBuilder: (o, items) {
                      final List<OrderDetailModel> details = _convertItemsToDetails(items);
                      return is80mm
                          ? OrderTicket80mm(order: o, filteredDetails: details)
                          : OrderTicket58mm(order: o, filteredDetails: details);
                    },
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

  /* convertir OrderItemModel a OrderDetailModel para los tickets de orden completa */
  static List<OrderDetailModel> _convertItemsToDetails(List<OrderItemModel> items) {
    return items.map((item) {
      final List<OrderComboSelectionModel>? combos = item.comboSelections?.map((m) {
        return OrderComboSelectionModel(
          selectedProductName: m['selectedProductName'],
          quantity: int.tryParse(m['quantity'] ?? '1') ?? 1,
        );
      }).toList();

      return OrderDetailModel(
        productId: item.product.id,
        productName: item.productName,
        productType: item.product.productType,
        quantity: item.quantity,
        observations: item.comment,
        sizeLabel: item.selectedPrice?.sizeLabel,
        comboSelections: combos,
      );
    }).toList();
  }
}
