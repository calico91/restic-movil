import 'package:blue_thermal_printer/blue_thermal_printer.dart';
import 'package:intl/intl.dart';
import 'package:restic_movil/app/data/models/transaction_receipt_model.dart';
import 'package:restic_movil/core/utils/printers/printable_ticket.dart';
import 'package:restic_movil/core/utils/helpers/string_extensions.dart';
import 'package:restic_movil/core/utils/printers/printer_utils.dart';

class TransactionTicket implements PrintableTicket {
  final TransactionReceiptModel transaction;

  TransactionTicket({required this.transaction});

  @override
  Future<void> printReceipt(BlueThermalPrinter printer) async {
    final dateFormat = DateFormat('dd/MM/yyyy HH:mm');
    final String date = transaction.issuedAt != null
        ? dateFormat.format(DateTime.parse(transaction.issuedAt!))
        : dateFormat.format(DateTime.now());

    printer.printNewLine();

    // DATOS FISCALES
    if (transaction.fiscalData != null) {
      final fiscal = transaction.fiscalData!;
      if (fiscal.businessName != null &&
          fiscal.businessName!.trim().isNotEmpty) {
        printer.printCustom(fiscal.businessName!.withoutDiacritics, 3, 1);
      }

      if (fiscal.taxId != null && fiscal.taxId!.trim().isNotEmpty) {
        String digit =
            (fiscal.taxIdDigit != null && fiscal.taxIdDigit!.trim().isNotEmpty)
            ? "-${fiscal.taxIdDigit}"
            : "";
        printer.printCustom(
          "NIT: ${fiscal.taxId}$digit".withoutDiacritics,
          1,
          1,
        );
      }

      if (fiscal.address != null && fiscal.address!.trim().isNotEmpty) {
        printer.printCustom(fiscal.address!.withoutDiacritics, 1, 1);
      }

      String cityDept = '';
      if (fiscal.city != null && fiscal.city!.trim().isNotEmpty) {
        cityDept = fiscal.city!;
      }
      if (fiscal.department != null && fiscal.department!.trim().isNotEmpty) {
        cityDept += cityDept.isEmpty
            ? fiscal.department!
            : " - ${fiscal.department}";
      }
      if (cityDept.isNotEmpty) {
        printer.printCustom(cityDept.withoutDiacritics, 1, 1);
      }

      if (fiscal.phone != null && fiscal.phone!.trim().isNotEmpty) {
        printer.printCustom("Tel: ${fiscal.phone}".withoutDiacritics, 1, 1);
      }

      printer.printNewLine();

      if (fiscal.dianResolution != null &&
          fiscal.dianResolution!.trim().isNotEmpty) {
        printer.printCustom(
          "Resolucion DIAN: ${fiscal.dianResolution}".withoutDiacritics,
          1,
          1,
        );

        if (fiscal.resolutionNumberFrom != null &&
            fiscal.resolutionNumberTo != null) {
          printer.printCustom(
            "Autorizacion del ${fiscal.resolutionNumberFrom} al ${fiscal.resolutionNumberTo}"
                .withoutDiacritics,
            1,
            1,
          );
        }

        if (fiscal.resolutionStartDate != null &&
            fiscal.resolutionEndDate != null &&
            fiscal.resolutionStartDate!.trim().isNotEmpty &&
            fiscal.resolutionEndDate!.trim().isNotEmpty) {
          printer.printCustom(
            "Vigencia: ${fiscal.resolutionStartDate} al ${fiscal.resolutionEndDate}"
                .withoutDiacritics,
            1,
            1,
          );
        }
      }

      if (fiscal.taxRegime != null && fiscal.taxRegime!.trim().isNotEmpty) {
        printer.printCustom(
          "Regimen: ${fiscal.taxRegime}".withoutDiacritics,
          1,
          1,
        );
      }
    } else {
      printer.printCustom("RECIBO DE VENTA", 3, 1);
    }

    printer.printNewLine();

    // INFO DE LA TRANSACCION
    printer.printCustom(
      "FACTURA DE VENTA: ${transaction.transactionNumber ?? ''}"
          .withoutDiacritics,
      1,
      0,
    );
    printer.printCustom("Fecha: $date".withoutDiacritics, 1, 0);

    if (transaction.waiterName != null) {
      printer.printCustom(
        "Mesero: ${transaction.waiterName}".withoutDiacritics,
        1,
        0,
      );
    }

    if (transaction.customerName != null) {
      printer.printCustom(
        "Cliente: ${transaction.customerName}".withoutDiacritics,
        1,
        0,
      );
    }

    if (transaction.tableNames != null && transaction.tableNames!.isNotEmpty) {
      printer.printCustom(
        "Mesas: ${transaction.tableNames!.join(', ')}".withoutDiacritics,
        1,
        0,
      );
    }

    printer.printCustom("--------------------------------", 1, 1);

    // PRODUCTOS
    printer.printCustom("PRODUCTOS", 1, 1);
    printer.printCustom("--------------------------------", 1, 1);

    final details = transaction.items ?? [];
    for (var item in details) {
      // Nombre en una línea para permitir descripciones más largas
      String itemName = (item.productName ?? 'Producto').withoutDiacritics;
      printer.printCustom(itemName, 1, 0);

      // Cantidad x Precio Unitario a la izquierda, Total a la derecha
      String qtyStr = item.quantity.toString();
      String unitPrice = PrinterUtils.formatCurrency(item.unitPrice ?? 0);
      String subtotal = PrinterUtils.formatCurrency(item.subtotal ?? 0);

      String lineLeft = "  $qtyStr x $unitPrice";
      String lineRight = subtotal;

      int spaces = 32 - (lineLeft.length + lineRight.length);
      if (spaces < 1) spaces = 1;

      printer.printCustom((lineLeft + (' ' * spaces) + lineRight).withoutDiacritics, 1, 0);
    }

    printer.printCustom("--------------------------------", 1, 1);

    // TOTALES
    double subtotal = transaction.subtotal ?? 0.0;
    PrinterUtils.printCurrencyRow(printer, "Subtotal:       ", subtotal, 1);

    PrinterUtils.printSurcharges(printer, transaction.surcharges);

    if ((transaction.tipAmount ?? 0) > 0) {
      PrinterUtils.printCurrencyRow(
        printer,
        "Propina:        ",
        transaction.tipAmount!,
        1,
      );
    }
    PrinterUtils.printCurrencyRow(
      printer,
      "TOTAL A PAGAR:  ",
      transaction.totalAmount ?? 0,
      2,
    );

    printer.printNewLine();

    PrinterUtils.printCurrencyRow(
      printer,
      "Total Pagado:   ",
      transaction.totalPaid ?? 0,
      1,
    );
    PrinterUtils.printCurrencyRow(
      printer,
      "Cambio:         ",
      transaction.change ?? 0,
      1,
    );

    printer.printNewLine();
    if (transaction.paymentDetails != null &&
        transaction.paymentDetails!.isNotEmpty) {
      printer.printCustom("Metodos de pago:", 1, 1);
      for (var pay in transaction.paymentDetails!) {
        String payAmount = PrinterUtils.formatCurrency(pay.amount ?? 0);
        String methodDesc =
            pay.paymentMethodDescription ?? pay.paymentMethod ?? 'Desconocido';
        printer.printCustom("$methodDesc: $payAmount".withoutDiacritics, 1, 1);
      }
    }

    printer.printNewLine();
    printer.printCustom("GRACIAS POR SU COMPRA!", 1, 1);
    printer.printNewLine();
    printer.printNewLine();
    printer.printNewLine();

    // CORTAR PAPEL
    printer.paperCut();
  }
}
