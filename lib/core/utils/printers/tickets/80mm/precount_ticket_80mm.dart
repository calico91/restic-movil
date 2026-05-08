import 'package:restic_movil/core/utils/printers/thermal_printer_port.dart';
import 'package:intl/intl.dart';
import 'package:restic_movil/app/data/models/order_model.dart';
import 'package:restic_movil/core/utils/printers/printable_ticket.dart';
import 'package:restic_movil/core/utils/helpers/string_extensions.dart';
import 'package:restic_movil/core/utils/printers/printer_utils.dart';

// Ticket de precuenta para impresora de 80mm (48 chars por línea)
class PrecountTicket80mm implements PrintableTicket {
  final OrderModel order;
  final double tipPercentage;

  PrecountTicket80mm({required this.order, required this.tipPercentage});

  static const String _sep = '------------------------------------------------'; // 48 chars
  static const int _lineWidth = 48;

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
    printer.printCustom('Orden: #${order.orderNumber ?? ''}'.withoutDiacritics, 2, 0);
    printer.printCustom('Fecha: $dateStr'.withoutDiacritics, 2, 0);

    if (order.customer != null && order.customer!.fullName.isNotEmpty) {
      printer.printCustom('Cliente: ${order.customer!.fullName}'.withoutDiacritics, 2, 0);
    }
    if (order.tables != null && order.tables!.isNotEmpty) {
      final tableNames = order.tables!.map((e) => e.name).toList();
      printer.printCustom('Mesas: ${tableNames.join(', ')}'.withoutDiacritics, 2, 0);
    }

    printer.printCustom(_sep, 1, 1);
    printer.printCustom('PRODUCTOS', 2, 1);
    printer.printCustom(_sep, 1, 1);

    // Construye el nombre visible incluyendo acompañante si el ítem es COMBINADO
    final String Function(String?, String?, String?) buildDisplayName =
        (pName, sizeLabel, obs) {
      final String after = (obs != null && obs.startsWith('COMBINADO: '))
          ? obs.substring('COMBINADO: '.length)
          : '';
      final int si = after.indexOf(' | ');
      final String companion =
          si >= 0 ? after.substring(0, si).trim() : after.trim();
      final String base = sizeLabel != null
          ? '${pName ?? 'Producto'} - $sizeLabel'
          : (pName ?? 'Producto');
      return (companion.isNotEmpty && !base.contains(companion))
          ? '$base + $companion'
          : base;
    };

    // Agrupar ítems por nombre visible + precio unitario para consolidar filas en la precuenta
    final Map<String, Map<String, Object>> grouped = {};
    for (final item in order.details ?? []) {
      if (item.status == 'Anulado') continue;
      final String name =
          buildDisplayName(item.productName, item.sizeLabel, item.observations);
      final double up = item.unitPrice ?? 0;
      final String key = '$name|$up';
      if (grouped.containsKey(key)) {
        grouped[key]!['qty'] = (grouped[key]!['qty'] as int) + (item.quantity ?? 1);
        grouped[key]!['sub'] =
            (grouped[key]!['sub'] as double) + (item.subtotal ?? 0.0);
      } else {
        grouped[key] = {
          'name': name,
          'qty': item.quantity ?? 1,
          'unitPrice': up,
          'sub': item.subtotal ?? 0.0,
        };
      }
    }

    for (final row in grouped.values) {
      printer.printCustom((row['name'] as String).withoutDiacritics, 2, 0);
      final String qtyStr = (row['qty'] as int).toString();
      final String unitPriceStr =
          PrinterUtils.formatCurrency(row['unitPrice'] as double);
      final String subtotalStr = PrinterUtils.formatCurrency(row['sub'] as double);
      final String lineLeft = '  $qtyStr x $unitPriceStr';
      final int spaces =
          (_lineWidth - (lineLeft.length + subtotalStr.length)).clamp(1, _lineWidth);
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
    printer.printCustom('TOTAL A PAGAR: ${PrinterUtils.formatCurrency(total)}'.withoutDiacritics, 2, 1);

    printer.printNewLine();
    printer.printCustom('Revise su consumo antes de pagar.', 1, 1);
    printer.printCustom('GRACIAS POR SU VISITA!', 2, 1);
    printer.printNewLine();
    printer.printNewLine();
    printer.printNewLine();
    printer.paperCut();
  }
}
