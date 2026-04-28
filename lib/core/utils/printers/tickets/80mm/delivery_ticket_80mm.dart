import 'package:restic_movil/core/utils/printers/thermal_printer_port.dart';
import 'package:intl/intl.dart';
import 'package:restic_movil/app/data/models/order_model.dart';
import 'package:restic_movil/core/utils/printers/printable_ticket.dart';
import 'package:restic_movil/core/utils/helpers/string_extensions.dart';
import 'package:restic_movil/core/utils/printers/printer_utils.dart';

// Ticket de delivery para impresora de 80mm (48 chars por línea)
class DeliveryTicket80mm implements PrintableTicket {
  final OrderModel order;

  DeliveryTicket80mm({required this.order});

  static const String _sep = '------------------------------------------------'; // 48 chars

  @override
  Future<void> printReceipt(ThermalPrinterPort printer) async {
    final dateFormat = DateFormat('dd/MM/yyyy HH:mm');
    final String date = order.openingDate != null
        ? dateFormat.format(DateTime.parse(order.openingDate!))
        : dateFormat.format(DateTime.now());

    printer.printNewLine();
    printer.printCustom('REPARTO / DELIVERY', 3, 1);
    printer.printNewLine();

    printer.printCustom('Orden: #${order.orderNumber}'.withoutDiacritics, 2, 0);
    printer.printCustom('Fecha: $date'.withoutDiacritics, 1, 0);

    printer.printCustom(_sep, 1, 1);
    printer.printCustom('Cliente: ${order.customer?.fullName ?? 'N/A'}'.withoutDiacritics, 1, 0);

    if (order.customer?.address != null && order.customer!.address!.isNotEmpty) {
      printer.printCustom('Direccion: ${order.customer!.address}'.withoutDiacritics, 1, 0);
    }
    if (order.customer?.phone != null && order.customer!.phone!.isNotEmpty) {
      printer.printCustom('Telefono: ${order.customer!.phone}'.withoutDiacritics, 1, 0);
    }
    if (order.observations != null && order.observations!.trim().isNotEmpty) {
      printer.printNewLine();
      printer.printCustom('OBSERVACION GENERAL:', 1, 1);
      printer.printCustom(order.observations!.withoutDiacritics, 1, 1);
    }

    printer.printCustom(_sep, 1, 1);
    printer.printCustom('CANT.   PRODUCTO', 2, 0);
    printer.printCustom(_sep, 1, 1);

    final details = order.details ?? [];
    for (var item in details) {
      final pName = item.sizeLabel != null
          ? '${item.productName ?? 'Producto'} - ${item.sizeLabel}'
          : (item.productName ?? 'Producto');
      printer.printCustom('${item.quantity}x  $pName'.withoutDiacritics, 2, 0);

      if (item.comboSelections != null && item.comboSelections!.isNotEmpty) {
        for (var combo in item.comboSelections!) {
          printer.printCustom(
            '    > ${combo.quantity ?? 1}x ${combo.selectedProductName ?? 'Extra'}'.withoutDiacritics,
            1,
            0,
          );
        }
      }
      if (item.observations != null && item.observations!.trim().isNotEmpty) {
        printer.printCustom('    [Nota: ${item.observations}]'.withoutDiacritics, 1, 0);
      }
      printer.printNewLine();
    }

    printer.printCustom(_sep, 1, 1);

    final double subtotal = order.subtotal ?? (order.total ?? 0.0);
    final double total = order.total ?? 0.0;

    PrinterUtils.printCurrencyRow(printer, 'Subtotal:       ', subtotal, 1);
    PrinterUtils.printSurcharges(printer, order.surcharges);
    PrinterUtils.printCurrencyRow(printer, 'TOTAL A COBRAR: ', total, 2);

    printer.printNewLine();
    printer.printCustom('Gracias por su compra!', 1, 1);
    printer.printNewLine();
    printer.printNewLine();
    printer.printNewLine();
    printer.paperCut();
  }
}
