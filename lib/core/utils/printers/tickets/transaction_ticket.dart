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
      if (fiscal.businessName != null && fiscal.businessName!.trim().isNotEmpty) {
        printer.printCustom(fiscal.businessName!.withoutDiacritics, 3, 1);
      }
      
      if (fiscal.taxId != null && fiscal.taxId!.trim().isNotEmpty) {
        String digit = (fiscal.taxIdDigit != null && fiscal.taxIdDigit!.trim().isNotEmpty) ? "-${fiscal.taxIdDigit}" : "";
        printer.printCustom("NIT: ${fiscal.taxId}$digit".withoutDiacritics, 1, 1);
      }
      
      if (fiscal.address != null && fiscal.address!.trim().isNotEmpty) {
        printer.printCustom(fiscal.address!.withoutDiacritics, 1, 1);
      }
      
      String cityDept = '';
      if (fiscal.city != null && fiscal.city!.trim().isNotEmpty) {
        cityDept = fiscal.city!;
      }
      if (fiscal.department != null && fiscal.department!.trim().isNotEmpty) {
        cityDept += cityDept.isEmpty ? fiscal.department! : " - ${fiscal.department}";
      }
      if (cityDept.isNotEmpty) {
        printer.printCustom(cityDept.withoutDiacritics, 1, 1);
      }
      
      if (fiscal.phone != null && fiscal.phone!.trim().isNotEmpty) {
        printer.printCustom("Tel: ${fiscal.phone}".withoutDiacritics, 1, 1);
      }

      printer.printNewLine();

      if (fiscal.dianResolution != null && fiscal.dianResolution!.trim().isNotEmpty) {
        printer.printCustom("Resolucion DIAN: ${fiscal.dianResolution}".withoutDiacritics, 1, 1);
        
        if (fiscal.resolutionNumberFrom != null && fiscal.resolutionNumberTo != null) {
          printer.printCustom("Autorizacion del ${fiscal.resolutionNumberFrom} al ${fiscal.resolutionNumberTo}".withoutDiacritics, 1, 1);
        }
        
        if (fiscal.resolutionStartDate != null && fiscal.resolutionEndDate != null && 
            fiscal.resolutionStartDate!.trim().isNotEmpty && fiscal.resolutionEndDate!.trim().isNotEmpty) {
          printer.printCustom("Vigencia: ${fiscal.resolutionStartDate} al ${fiscal.resolutionEndDate}".withoutDiacritics, 1, 1);
        }
      }

      if (fiscal.taxRegime != null && fiscal.taxRegime!.trim().isNotEmpty) {
        printer.printCustom("Regimen: ${fiscal.taxRegime}".withoutDiacritics, 1, 1);
      }
    } else {
      printer.printCustom("RECIBO DE VENTA", 3, 1);
    }

    printer.printNewLine();

    // INFO DE LA TRANSACCION
    printer.printCustom("FACTURA DE VENTA: ${transaction.transactionNumber ?? ''}".withoutDiacritics, 1, 0);
    printer.printCustom("Fecha: $date".withoutDiacritics, 1, 0);
    
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
      // Formatear precio y eliminar cualquier caracter extraño o diacrítico que la impresora falle en interpretar
      String price = PrinterUtils.formatCurrency(item.subtotal ?? 0).padLeft(8);

      printer.printCustom("$qty $itemName".withoutDiacritics, 1, 0);
      printer.printCustom(price, 1, 2); // alinear a la derecha el precio
    }

    printer.printCustom("--------------------------------", 1, 1);

    // TOTALES
    PrinterUtils.printCurrencyRow(printer, "Subtotal:       ", transaction.subtotal ?? 0, 1);
    if ((transaction.tipAmount ?? 0) > 0) {
      PrinterUtils.printCurrencyRow(printer, "Propina:        ", transaction.tipAmount!, 1);
    }
    PrinterUtils.printCurrencyRow(printer, "TOTAL A PAGAR:  ", transaction.totalAmount ?? 0, 2);
    
    printer.printNewLine();
    
    PrinterUtils.printCurrencyRow(printer, "Total Pagado:   ", transaction.totalPaid ?? 0, 1);
    PrinterUtils.printCurrencyRow(printer, "Cambio:         ", transaction.change ?? 0, 1);

    printer.printNewLine();
    if (transaction.paymentDetails != null && transaction.paymentDetails!.isNotEmpty) {
      printer.printCustom("Metodos de pago:", 1, 1);
      for (var pay in transaction.paymentDetails!) {
        String payAmount = PrinterUtils.formatCurrency(pay.amount ?? 0);
        String methodDesc = pay.paymentMethodDescription ?? pay.paymentMethod ?? 'Desconocido';
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
