import 'package:blue_thermal_printer/blue_thermal_printer.dart';
import 'package:intl/intl.dart';
import 'package:restic_movil/app/data/models/order_model.dart';
import 'package:restic_movil/core/utils/formatters/currency_formatter.dart';
import 'package:restic_movil/core/utils/printers/printable_ticket.dart';

class OrderTicket implements PrintableTicket {
  final OrderModel order;

  OrderTicket({required this.order});

  @override
  Future<void> printReceipt(BlueThermalPrinter printer) async {
    final dateFormat = DateFormat('dd/MM/yyyy HH:mm');
    final String date = order.openingDate != null
        ? dateFormat.format(DateTime.parse(order.openingDate!))
        : dateFormat.format(DateTime.now());

    // ENCABEZADO
    printer.printNewLine();
    printer.printCustom("RESTIC MOVIL", 3, 1);
    printer.printNewLine();
    printer.printCustom("Comprobante de Venta", 1, 1);
    printer.printNewLine();

    // INFO DE LA ORDEN
    printer.printLeftRight(
      "Orden: #${order.orderNumber}",
      "Fecha: $date",
      1,
    );

    String originLabel = "Origen: ${order.originType ?? 'N/A'}";
    if (order.originType == 'SALON' || order.originType == 'MESA') {
      final tables = order.tables?.map((e) => e.name).join(', ') ?? 'N/A';
      originLabel = "Mesa: $tables";
    } else if (order.customerName != null) {
      originLabel = "Cliente: ${order.customerName}";
    }

    printer.printCustom(originLabel, 1, 0);

    if (order.observations != null && order.observations!.trim().isNotEmpty) {
      printer.printCustom("Notas: ${order.observations}", 1, 0);
    }

    printer.printCustom("--------------------------------", 1, 1);

    // PRODUCTOS
    printer.printLeftRight(
      "Producto",
      "Subtotal",
      1,
      format: "%-20s %10s %n",
    );
    printer.printCustom("--------------------------------", 1, 1);

    final details = order.details ?? [];
    for (var item in details) {
      String itemName = "${item.quantity}x ${item.productName ?? 'P.'}";
      if (itemName.length > 20) {
        itemName = itemName.substring(0, 19);
      }
      String itemTotal = CurrencyFormatter.toCurrency(item.subtotal ?? 0);

      printer.printLeftRight(itemName, itemTotal, 1);

      // Imprimir observaciones del producto si existen
      if (item.observations != null && item.observations!.trim().isNotEmpty) {
        printer.printCustom("  * Nota: ${item.observations}", 1, 0);
      }

      // Imprimir selecciones del combo si existen
      if (item.comboSelections != null && item.comboSelections!.isNotEmpty) {
        for (var combo in item.comboSelections!) {
          String comboName =
              "  > ${combo.quantity ?? 1}x ${combo.selectedProductName ?? 'Extra'}";
          printer.printCustom(comboName, 1, 0);
        }
      }
    }

    printer.printCustom("--------------------------------", 1, 1);

    // TOTALES
    final totalStr = CurrencyFormatter.toCurrency(order.total ?? 0);
    printer.printLeftRight("TOTAL:", totalStr, 2);
    printer.printNewLine();

    // PIE DE PÁGINA
    printer.printCustom("¡Gracias por su compra!", 1, 1);
    printer.printNewLine();
    printer.printNewLine();
    printer.printNewLine();

    // CORTAR PAPEL Y ABRIR CAJA (Dependiendo de la impresora)
    printer.paperCut();
  }
}
