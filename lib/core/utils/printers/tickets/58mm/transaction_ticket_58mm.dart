import 'package:blue_thermal_printer/blue_thermal_printer.dart';
import 'package:intl/intl.dart';
import 'package:restic_movil/app/data/models/transaction_receipt_model.dart';
import 'package:restic_movil/core/utils/printers/printable_ticket.dart';
import 'package:restic_movil/core/utils/helpers/string_extensions.dart';
import 'package:restic_movil/core/utils/printers/printer_utils.dart';

// Ticket de factura/transacción para impresora de 58mm (32 chars por línea)
class TransactionTicket58mm implements PrintableTicket {
  final TransactionReceiptModel transaction;

  TransactionTicket58mm({required this.transaction});

  static const String _sep = '--------------------------------'; // 32 chars
  static const int _lineWidth = 32;

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
      if (fiscal.businessName != null && fiscal.businessName!.trim().isNotEmpty) {
        printer.printCustom(fiscal.businessName!.withoutDiacritics, 3, 1);
      }
      if (fiscal.taxId != null && fiscal.taxId!.trim().isNotEmpty) {
        final String digit =
            (fiscal.taxIdDigit != null && fiscal.taxIdDigit!.trim().isNotEmpty)
                ? '-${fiscal.taxIdDigit}'
                : '';
        printer.printCustom('NIT: ${fiscal.taxId}$digit'.withoutDiacritics, 1, 1);
      }
      if (fiscal.address != null && fiscal.address!.trim().isNotEmpty) {
        printer.printCustom(fiscal.address!.withoutDiacritics, 1, 1);
      }
      String cityDept = '';
      if (fiscal.city != null && fiscal.city!.trim().isNotEmpty) {
        cityDept = fiscal.city!;
      }
      if (fiscal.department != null && fiscal.department!.trim().isNotEmpty) {
        cityDept += cityDept.isEmpty ? fiscal.department! : ' - ${fiscal.department}';
      }
      if (cityDept.isNotEmpty) {
        printer.printCustom(cityDept.withoutDiacritics, 1, 1);
      }
      if (fiscal.phone != null && fiscal.phone!.trim().isNotEmpty) {
        printer.printCustom('Tel: ${fiscal.phone}'.withoutDiacritics, 1, 1);
      }
      printer.printNewLine();
      if (fiscal.dianResolution != null && fiscal.dianResolution!.trim().isNotEmpty) {
        printer.printCustom(
          'Resolucion DIAN: ${fiscal.dianResolution}'.withoutDiacritics,
          1,
          1,
        );
        if (fiscal.resolutionNumberFrom != null && fiscal.resolutionNumberTo != null) {
          printer.printCustom(
            'Autorizacion del ${fiscal.resolutionNumberFrom} al ${fiscal.resolutionNumberTo}'
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
            'Vigencia: ${fiscal.resolutionStartDate} al ${fiscal.resolutionEndDate}'
                .withoutDiacritics,
            1,
            1,
          );
        }
      }
      if (fiscal.taxRegime != null && fiscal.taxRegime!.trim().isNotEmpty) {
        printer.printCustom('Regimen: ${fiscal.taxRegime}'.withoutDiacritics, 1, 1);
      }
    } else {
      printer.printCustom('RECIBO DE VENTA', 3, 1);
    }

    printer.printNewLine();

    // INFO DE LA TRANSACCION
    printer.printCustom(
      'FACTURA DE VENTA: ${transaction.transactionNumber ?? ''}'.withoutDiacritics,
      1,
      0,
    );
    printer.printCustom('Fecha: $date'.withoutDiacritics, 1, 0);
    if (transaction.waiterName != null) {
      printer.printCustom('Mesero: ${transaction.waiterName}'.withoutDiacritics, 1, 0);
    }
    if (transaction.customerName != null) {
      printer.printCustom('Cliente: ${transaction.customerName}'.withoutDiacritics, 1, 0);
    }
    if (transaction.tableNames != null && transaction.tableNames!.isNotEmpty) {
      printer.printCustom(
        'Mesas: ${transaction.tableNames!.join(', ')}'.withoutDiacritics,
        1,
        0,
      );
    }

    printer.printCustom(_sep, 1, 1);
    printer.printCustom('PRODUCTOS', 1, 1);
    printer.printCustom(_sep, 1, 1);

    final items = transaction.items ?? [];
    for (var item in items) {
      printer.printCustom((item.productName ?? 'Producto').withoutDiacritics, 1, 0);

      final String qtyStr = item.quantity.toString();
      final String unitPrice = PrinterUtils.formatCurrency(item.unitPrice ?? 0);
      final String subtotal = PrinterUtils.formatCurrency(item.subtotal ?? 0);
      final String lineLeft = '  $qtyStr x $unitPrice';
      final int spaces = (_lineWidth - (lineLeft.length + subtotal.length)).clamp(1, _lineWidth);
      printer.printCustom((lineLeft + (' ' * spaces) + subtotal).withoutDiacritics, 1, 0);
    }

    printer.printCustom(_sep, 1, 1);

    // TOTALES
    final double subtotal = transaction.subtotal ?? 0.0;
    PrinterUtils.printCurrencyRow(printer, 'Subtotal:       ', subtotal, 1);
    PrinterUtils.printSurcharges(printer, transaction.surcharges);
    if ((transaction.tipAmount ?? 0) > 0) {
      PrinterUtils.printCurrencyRow(printer, 'Propina:        ', transaction.tipAmount!, 1);
    }
    PrinterUtils.printCurrencyRow(printer, 'TOTAL A PAGAR:  ', transaction.totalAmount ?? 0, 2);
    printer.printNewLine();
    PrinterUtils.printCurrencyRow(printer, 'Total Pagado:   ', transaction.totalPaid ?? 0, 1);
    PrinterUtils.printCurrencyRow(printer, 'Cambio:         ', transaction.change ?? 0, 1);

    printer.printNewLine();
    if (transaction.paymentDetails != null && transaction.paymentDetails!.isNotEmpty) {
      printer.printCustom('Metodos de pago:', 1, 1);
      for (var pay in transaction.paymentDetails!) {
        final String payAmount = PrinterUtils.formatCurrency(pay.amount ?? 0);
        final String methodDesc =
            pay.paymentMethodDescription ?? pay.paymentMethod ?? 'Desconocido';
        printer.printCustom('$methodDesc: $payAmount'.withoutDiacritics, 1, 1);
      }
    }

    printer.printNewLine();
    printer.printCustom('GRACIAS POR SU COMPRA!', 1, 1);
    printer.printNewLine();
    printer.printNewLine();
    printer.printNewLine();
    printer.paperCut();
  }
}
