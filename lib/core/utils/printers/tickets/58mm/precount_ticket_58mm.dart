import 'package:restic_movil/core/utils/printers/thermal_printer_port.dart';
import 'package:intl/intl.dart';
import 'package:restic_movil/app/data/models/order_model.dart';
import 'package:restic_movil/core/utils/printers/printable_ticket.dart';
import 'package:restic_movil/core/utils/helpers/string_extensions.dart';
import 'package:restic_movil/core/utils/printers/printer_utils.dart';

// Ticket de precuenta para impresora de 58mm (32 chars por línea)
class PrecountTicket58mm implements PrintableTicket {
  final OrderModel order;
  final double tipPercentage;

  PrecountTicket58mm({required this.order, required this.tipPercentage});

  static const String _sep = '--------------------------------'; // 32 chars
  static const int _lineWidth = 32;

  @override
  Future<void> printReceipt(ThermalPrinterPort printer) async {
    final dateFormat = DateFormat('dd/MM/yyyy HH:mm');
    String dateStr;
    if (order.openingDate != null) {
      final parsedDate = DateTime.tryParse(order.openingDate as String);
      dateStr = parsedDate != null
          ? dateFormat.format(parsedDate)
          : dateFormat.format(DateTime.now());
    } else {
      dateStr = dateFormat.format(DateTime.now());
    }

    printer.printCustom(
      'Este documento NO es una factura valida'.withoutDiacritics,
      1,
      1,
    );
    printer.printNewLine();

    // INFO DE LA ORDEN
    printer.printCustom('Orden: #${order.orderNumber ?? ''}'.withoutDiacritics, 1, 0);
    printer.printCustom('Fecha: $dateStr'.withoutDiacritics, 1, 0);

    if (order.customer != null && order.customer!.fullName.isNotEmpty) {
      printer.printCustom('Cliente: ${order.customer!.fullName}'.withoutDiacritics, 1, 0);
    }
    if (order.tables != null && order.tables!.isNotEmpty) {
      final tableNames = order.tables!.map((e) => e.name).toList();
      printer.printCustom('Mesas: ${tableNames.join(', ')}'.withoutDiacritics, 1, 0);
    }

    printer.printCustom(_sep, 1, 1);
    printer.printCustom('PRODUCTOS', 1, 1);
    printer.printCustom(_sep, 1, 1);

    final details = order.details ?? [];
    for (var item in details) {
      if (item.status == 'Anulado') continue;

      // Nombre con talla si aplica
      final String rawName = item.sizeLabel != null
          ? '${item.productName ?? 'Producto'} - ${item.sizeLabel}'
          : (item.productName ?? 'Producto');
      printer.printCustom(rawName.withoutDiacritics, 1, 0);

      // Cantidad x Precio unitario | Subtotal alineado a la derecha
      final String qtyStr = item.quantity.toString();
      final String unitPriceStr = PrinterUtils.formatCurrency(item.unitPrice ?? 0);
      final String subtotalStr = PrinterUtils.formatCurrency(item.subtotal ?? 0);
      final String lineLeft = '  $qtyStr x $unitPriceStr';
      final int spaces = (_lineWidth - (lineLeft.length + subtotalStr.length)).clamp(1, _lineWidth);
      printer.printCustom(
        (lineLeft + (' ' * spaces) + subtotalStr).withoutDiacritics,
        1,
        0,
      );
    }

    printer.printCustom(_sep, 1, 1);

    // TOTALES
    final double subtotal = order.subtotal ?? (order.total ?? 0.0);
    final double tipAmount = subtotal * (tipPercentage / 100);
    final double total = (order.total ?? 0.0) + tipAmount;

    PrinterUtils.printCurrencyRow(printer, 'Subtotal:       ', subtotal, 1);
    PrinterUtils.printSurcharges(printer, order.surcharges);

    final String tipLabel = 'Servicio (${tipPercentage.toStringAsFixed(0)}%):'.padRight(16);
    PrinterUtils.printCurrencyRow(printer, tipLabel, tipAmount, 1);
    PrinterUtils.printCurrencyRow(printer, 'TOTAL A PAGAR:  ', total, 2);

    printer.printNewLine();
    printer.printCustom('Revise su consumo antes de pagar.', 1, 1);
    printer.printCustom('GRACIAS POR SU VISITA!', 1, 1);
    printer.printNewLine();
    printer.printNewLine();
    printer.printNewLine();
    printer.paperCut();
  }
}
