import 'package:blue_thermal_printer/blue_thermal_printer.dart';
import 'package:intl/intl.dart';
import 'package:restic_movil/app/data/models/transaction_receipt_model.dart';
import 'package:restic_movil/core/utils/printers/printable_ticket.dart';
import 'package:restic_movil/core/utils/helpers/string_extensions.dart';

class TransactionTicket implements PrintableTicket {
  final TransactionReceiptModel transaction;

  TransactionTicket({required this.transaction});

  @override
  Future<void> printReceipt(BlueThermalPrinter printer) async {
    final dateFormat = DateFormat('dd/MM/yyyy HH:mm');
    final String date = transaction.issuedAt != null
        ? dateFormat.format(DateTime.parse(transaction.issuedAt!))
        : dateFormat.format(DateTime.now());

    final currencyFormat = NumberFormat.currency(
      locale: 'es_CO',
      symbol: '\$',
      decimalDigits: 0,
    );

    printer.printNewLine();

    // DATOS FISCALES
    if (transaction.fiscalData != null) {
      final fiscal = transaction.fiscalData!;
      if (fiscal.businessName != null) {
        printer.printCustom(fiscal.businessName!.withoutDiacritics, 3, 1);
      }
      
      if (fiscal.taxId != null) {
        printer.printCustom("NIT: ${fiscal.taxId}-${fiscal.taxIdDigit ?? ''}".withoutDiacritics, 1, 1);
      }
      
      if (fiscal.address != null) {
        printer.printCustom(fiscal.address!.withoutDiacritics, 1, 1);
      }
      
      if (fiscal.city != null || fiscal.department != null) {
        printer.printCustom("${fiscal.city ?? ''} - ${fiscal.department ?? ''}".withoutDiacritics, 1, 1);
      }
      
      if (fiscal.phone != null) {
        printer.printCustom("Tel: ${fiscal.phone}".withoutDiacritics, 1, 1);
      }

      printer.printNewLine();

      if (fiscal.dianResolution != null) {
        printer.printCustom("Resolucion DIAN: ${fiscal.dianResolution}".withoutDiacritics, 1, 1);
        printer.printCustom("Autorizacion del ${fiscal.resolutionNumberFrom ?? ''} al ${fiscal.resolutionNumberTo ?? ''}".withoutDiacritics, 1, 1);
        if (fiscal.resolutionStartDate != null && fiscal.resolutionEndDate != null) {
          printer.printCustom("Vigencia: ${fiscal.resolutionStartDate} al ${fiscal.resolutionEndDate}".withoutDiacritics, 1, 1);
        }
      }

      if (fiscal.taxRegime != null) {
        printer.printCustom("Regimen: ${fiscal.taxRegime}".withoutDiacritics, 1, 1);
      }
    } else {
      printer.printCustom("RECIBO DE VENTA", 3, 1);
    }

    printer.printNewLine();

    // INFO DE LA TRANSACCION
    printer.printCustom("FACTURA DE VENTA: ${transaction.transactionNumber ?? ''}".withoutDiacritics, 1, 0);
    printer.printCustom("Fecha: $date".withoutDiacritics, 1, 0);
    printer.printCustom("Cajero: ${transaction.cashierId ?? 'N/A'}".withoutDiacritics, 1, 0); // Idealmente cambiar por nombre si viene
    
    if (transaction.waiterName != null) {
      printer.printCustom("Mesero: ${transaction.waiterName}".withoutDiacritics, 1, 0);
    }
    
    if (transaction.customerName != null) {
      printer.printCustom("Cliente: ${transaction.customerName}".withoutDiacritics, 1, 0);
    }

    if (transaction.tableNames != null && transaction.tableNames!.isNotEmpty) {
      printer.printCustom("Mesas: ${transaction.tableNames!.join(', ')}".withoutDiacritics, 1, 0);
    }

    printer.printCustom("--------------------------------", 1, 1);

    // PRODUCTOS A PREPARAR
    printer.printCustom("CANT  DESCRIPCION       TOTAL", 1, 0);
    printer.printCustom("--------------------------------", 1, 1);

    final details = transaction.items ?? [];
    for (var item in details) {
      // Nombre y cantidad
      String itemName = item.productName ?? 'Producto';
      if (itemName.length > 20) {
        itemName = itemName.substring(0, 20); // limitar largo
      }
      
      String qty = item.quantity.toString().padRight(4);
      String price = currencyFormat.format(item.subtotal).padLeft(8);

      printer.printCustom("$qty $itemName", 1, 0);
      printer.printCustom(price, 1, 2); // alinear a la derecha el precio
    }

    printer.printCustom("--------------------------------", 1, 1);

    // TOTALES
    printer.printCustom("Subtotal:       ${currencyFormat.format(transaction.subtotal ?? 0)}".withoutDiacritics, 1, 2);
    if ((transaction.tipAmount ?? 0) > 0) {
      printer.printCustom("Propina:        ${currencyFormat.format(transaction.tipAmount)}".withoutDiacritics, 1, 2);
    }
    printer.printCustom("TOTAL A PAGAR:  ${currencyFormat.format(transaction.totalAmount ?? 0)}".withoutDiacritics, 2, 2);
    
    printer.printNewLine();
    
    printer.printCustom("Total Pagado:   ${currencyFormat.format(transaction.totalPaid ?? 0)}".withoutDiacritics, 1, 2);
    printer.printCustom("Cambio:         ${currencyFormat.format(transaction.change ?? 0)}".withoutDiacritics, 1, 2);

    printer.printNewLine();
    if (transaction.paymentDetails != null && transaction.paymentDetails!.isNotEmpty) {
      printer.printCustom("Metodos de pago:", 1, 1);
      for (var pay in transaction.paymentDetails!) {
        printer.printCustom("${pay.paymentMethod}: ${currencyFormat.format(pay.amount ?? 0)}".withoutDiacritics, 1, 1);
      }
    }

    printer.printNewLine();
    printer.printCustom("¡GRACIAS POR SU COMPRA!", 1, 1);
    printer.printNewLine();
    printer.printNewLine();
    printer.printNewLine();

    // CORTAR PAPEL
    printer.paperCut();
  }
}
