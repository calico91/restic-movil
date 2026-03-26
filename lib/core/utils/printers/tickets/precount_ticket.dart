import 'package:blue_thermal_printer/blue_thermal_printer.dart';
import 'package:intl/intl.dart';
import 'package:restic_movil/app/data/models/order_model.dart';
import 'package:restic_movil/core/utils/printers/printable_ticket.dart';
import 'package:restic_movil/core/utils/helpers/string_extensions.dart';

class PrecountTicket implements PrintableTicket {
  final OrderModel order;
  final double tipPercentage;

  PrecountTicket({required this.order, required this.tipPercentage});

  @override
  Future<void> printReceipt(BlueThermalPrinter printer) async {
    final dateFormat = DateFormat('dd/MM/yyyy HH:mm');
    String dateStr;

    if (order.openingDate != null) {
      if (order.openingDate is String) {
        final parsedDate = DateTime.tryParse(order.openingDate as String);
        dateStr = parsedDate != null
            ? dateFormat.format(parsedDate)
            : dateFormat.format(DateTime.now());
      } else if (order.openingDate is DateTime) {
        dateStr = dateFormat.format(order.openingDate as DateTime);
      } else {
        dateStr = dateFormat.format(DateTime.now());
      }
    } else {
      dateStr = dateFormat.format(DateTime.now());
    }

    final currencyFormat = NumberFormat.currency(
      locale: 'en_US',
      symbol: '\$',
      decimalDigits: 0,
    );

    printer.printNewLine();

    printer.printCustom(
      "Este documento NO es una factura valida".withoutDiacritics,
      1,
      1,
    );

    printer.printNewLine();

    // INFO DE LA ORDEN
    printer.printCustom(
      "Orden: #${order.orderNumber ?? ''}".withoutDiacritics,
      1,
      0,
    );
    printer.printCustom("Fecha: $dateStr".withoutDiacritics, 1, 0);

    if (order.customerName != null && order.customerName!.isNotEmpty) {
      printer.printCustom(
        "Cliente: ${order.customerName}".withoutDiacritics,
        1,
        0,
      );
    }

    if (order.tables != null && order.tables!.isNotEmpty) {
      final tableNames = order.tables!.map((e) => e.name).toList();
      printer.printCustom(
        "Mesas: ${tableNames.join(', ')}".withoutDiacritics,
        1,
        0,
      );
    }

    printer.printCustom("--------------------------------", 1, 1);

    // PRODUCTOS A PREPARAR
    printer.printCustom("CANT  DESCRIPCION       TOTAL", 1, 0);
    printer.printCustom("--------------------------------", 1, 1);

    final details = order.details ?? [];
    for (var item in details) {
      if (item.status == 'Anulado') continue;

      // Nombre y cantidad
      String itemName = item.productName ?? 'Producto';
      if (itemName.length > 20) {
        itemName = itemName.substring(0, 20); // limitar largo
      }

      String qty = item.quantity.toString().padRight(4);
      // Formatear precio y eliminar cualquier caracter extraño o diacrítico que la impresora falle en interpretar
      String price = currencyFormat
          .format(item.subtotal)
          .replaceAll(RegExp(r'[^\x20-\x7E]'), '')
          .padLeft(8);

      printer.printCustom("$qty $itemName".withoutDiacritics, 1, 0);
      printer.printCustom(price, 1, 2); // alinear a la derecha el precio
    }

    printer.printCustom("--------------------------------", 1, 1);

    // Función auxiliar para imprimir texto con formato de moneda limpio
    void printCurrencyRow(String label, double amount, int size) {
      String formattedAmount = currencyFormat
          .format(amount)
          .replaceAll(RegExp(r'[^\x20-\x7E]'), '')
          .padLeft(
            12,
          ); // Pad fijo para evitar que el label se desplace si el monto cambia de longitud
      printer.printCustom("$label$formattedAmount".withoutDiacritics, size, 2);
    }

    // CALCULOS
    final subtotal = order.total ?? 0.0;
    final tipAmount = subtotal * (tipPercentage / 100);
    final total = subtotal + tipAmount;

    // TOTALES
    printCurrencyRow("Subtotal:       ", subtotal, 1);

    // Mostrar porcentaje en la etiqueta de la propina si es aplicable
    String tipLabel = tipPercentage > 0
        ? "Servicio (${tipPercentage.toStringAsFixed(0)}%): "
        : "Servicio:        ";

    // Asegurar que la etiqueta se alinee correctamente
    tipLabel = tipLabel.padRight(16);
    printCurrencyRow(tipLabel, tipAmount, 1);

    printCurrencyRow("TOTAL A PAGAR:  ", total, 2);

    printer.printNewLine();
    printer.printCustom("Revise su consumo antes de pagar.", 1, 1);
    printer.printCustom("GRACIAS POR SU VISITA!", 1, 1);
    printer.printNewLine();
    printer.printNewLine();
    printer.printNewLine();

    // CORTAR PAPEL
    printer.paperCut();
  }
}
