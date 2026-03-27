import 'package:blue_thermal_printer/blue_thermal_printer.dart';
import 'package:intl/intl.dart';
import 'package:restic_movil/app/data/models/order_model.dart';
import 'package:restic_movil/core/utils/printers/printable_ticket.dart';
import 'package:restic_movil/core/utils/helpers/string_extensions.dart';
import 'package:restic_movil/core/utils/printers/printer_utils.dart';

class DeliveryTicket implements PrintableTicket {
  final OrderModel order;

  DeliveryTicket({required this.order});

  @override
  Future<void> printReceipt(BlueThermalPrinter printer) async {
    final dateFormat = DateFormat('dd/MM/yyyy HH:mm');
    final String date = order.openingDate != null
        ? dateFormat.format(DateTime.parse(order.openingDate!))
        : dateFormat.format(DateTime.now());

    printer.printNewLine();

    printer.printCustom("REPARTO / DELIVERY", 3, 1);
    printer.printNewLine();

    printer.printCustom("Orden: #${order.orderNumber}".withoutDiacritics, 2, 0);
    printer.printCustom("Fecha: $date".withoutDiacritics, 1, 0);
    
    printer.printCustom("--------------------------------", 1, 1);
    printer.printCustom("Cliente: ${(order.customer?.fullName ?? 'N/A')}".withoutDiacritics, 1, 0);
    
    if (order.customer?.address != null && order.customer!.address!.isNotEmpty) {
      printer.printCustom("Direccion: ${order.customer!.address}".withoutDiacritics, 1, 0);
    }
    
    if (order.customer?.phone != null && order.customer!.phone!.isNotEmpty) {
      printer.printCustom("Telefono: ${order.customer!.phone}".withoutDiacritics, 1, 0);
    }
    
    if (order.observations != null && order.observations!.trim().isNotEmpty) {
      printer.printNewLine();
      printer.printCustom("OBSERVACION GENERAL:", 1, 1);
      printer.printCustom(order.observations!.withoutDiacritics, 1, 1);
    }

    printer.printCustom("--------------------------------", 1, 1);

    printer.printCustom("CANT.   PRODUCTO", 2, 0);
    printer.printCustom("--------------------------------", 1, 1);

    final details = order.details ?? [];
    for (var item in details) {
      String itemName = "${item.quantity}x  ${item.productName ?? 'Producto'}";
      printer.printCustom(itemName.withoutDiacritics, 2, 0);

      if (item.comboSelections != null && item.comboSelections!.isNotEmpty) {
        for (var combo in item.comboSelections!) {
          String comboName = "    > ${combo.quantity ?? 1}x ${combo.selectedProductName ?? 'Extra'}";
          printer.printCustom(comboName.withoutDiacritics, 1, 0);
        }
      }

      if (item.observations != null && item.observations!.trim().isNotEmpty) {
        printer.printCustom("    [Nota: ${item.observations}]".withoutDiacritics, 1, 0);
      }
      printer.printNewLine();
    }

    printer.printCustom("--------------------------------", 1, 1);
    
    // Suma del total de la orden
    double subtotal = order.total ?? 0.0;
    
    PrinterUtils.printCurrencyRow(printer, "Subtotal:       ", subtotal, 1);
    PrinterUtils.printCurrencyRow(printer, "TOTAL A COBRAR: ", subtotal, 2);
    
    printer.printNewLine();
    printer.printCustom("Gracias por su compra!", 1, 1);
    printer.printNewLine();
    printer.printNewLine();
    printer.printNewLine();

    // CORTAR PAPEL
    printer.paperCut();
  }
}
