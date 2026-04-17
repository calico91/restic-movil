import 'package:blue_thermal_printer/blue_thermal_printer.dart';
import 'package:intl/intl.dart';
import 'package:restic_movil/app/data/models/order_model.dart';
import 'package:restic_movil/core/utils/printers/printable_ticket.dart';
import 'package:restic_movil/core/utils/helpers/string_extensions.dart';

class OrderTicket implements PrintableTicket {
  final OrderModel order;

  OrderTicket({required this.order});

  @override
  Future<void> printReceipt(BlueThermalPrinter printer) async {
    final dateFormat = DateFormat('dd/MM/yyyy HH:mm');
    final String date = order.openingDate != null
        ? dateFormat.format(DateTime.parse(order.openingDate!))
        : dateFormat.format(DateTime.now());

    // TICKET DE COCINA
    printer.printNewLine();
    printer.printCustom("PEDIDO", 3, 1);
    printer.printNewLine();

    // INFO DE LA ORDEN
    printer.printCustom("Orden: #${order.orderNumber}".withoutDiacritics, 1, 0);
    printer.printCustom("Fecha: $date".withoutDiacritics, 1, 0);
    printer.printCustom("Origen: ${order.originType?.description ?? 'N/A'}".withoutDiacritics, 1, 0);

    String extraInfo = "";
    if (order.originType?.code == 'SALON') {
      final tables = order.tables?.map((e) => e.name).join(', ') ?? 'N/A';
      extraInfo = "Mesas: $tables";
      printer.printCustom(extraInfo.withoutDiacritics, 1, 0);
      
      if (order.customer != null) {
        printer.printCustom("Cliente: ${order.customer!.fullName}".withoutDiacritics, 1, 0);
      }
    } else if (order.originType?.code == 'DELIVERY' ||
        order.originType?.code == 'TAKE_AWAY') {
      extraInfo = "Cliente: ${order.customer?.fullName ?? 'N/A'}";
      printer.printCustom(extraInfo.withoutDiacritics, 1, 0);

      if (order.customer?.address != null && order.customer!.address!.isNotEmpty) {
        printer.printCustom("Direccion: ${order.customer!.address}".withoutDiacritics, 1, 0);
      }
      if (order.customer?.phone != null && order.customer!.phone!.isNotEmpty) {
        printer.printCustom("Telefono: ${order.customer!.phone}".withoutDiacritics, 1, 0);
      }
    } else if (order.customer != null) {
      extraInfo = "Cliente: ${order.customer!.fullName}";
      printer.printCustom(extraInfo.withoutDiacritics, 1, 0);
    }

    if (order.observations != null && order.observations!.trim().isNotEmpty) {
      printer.printNewLine();
      printer.printCustom("OBSERVACION GENERAL:", 1, 1);
      printer.printCustom(order.observations!.withoutDiacritics, 1, 1);
      printer.printNewLine();
    }

    printer.printCustom("--------------------------------", 1, 1);

    // PRODUCTOS A PREPARAR
    printer.printCustom("CANT.   PRODUCTO", 2, 0);
    printer.printCustom("--------------------------------", 1, 1);

    final details = order.details ?? [];
    for (var item in details) {
      // Nombre y cantidad resaltados
      final pName = item.sizeLabel != null 
          ? '${item.productName ?? 'Producto'} - ${item.sizeLabel}' 
          : (item.productName ?? 'Producto');
      String itemName = "${item.quantity}x  $pName";
      printer.printCustom(
        itemName.withoutDiacritics,
        2,
        0,
      ); // Texto más grande para productos en cocina

      // Imprimir selecciones del combo si existen (Opciones del menú)
      if (item.comboSelections != null && item.comboSelections!.isNotEmpty) {
        for (var combo in item.comboSelections!) {
          String comboName =
              "    > ${combo.quantity ?? 1}x ${combo.selectedProductName ?? 'Extra'}";
          printer.printCustom(comboName.withoutDiacritics, 1, 0);
        }
      }

      // Imprimir observaciones específicas del producto debajo de las selecciones
      if (item.observations != null && item.observations!.trim().isNotEmpty) {
        printer.printCustom("    [Nota: ${item.observations}]".withoutDiacritics, 1, 0);
      }

      printer.printNewLine();
    }

    printer.printCustom("--------------------------------", 1, 1);
    printer.printNewLine();
    printer.printNewLine();
    printer.printNewLine();

    // CORTAR PAPEL
    printer.paperCut();
  }
}
