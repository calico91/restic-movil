import 'package:restic_movil/core/utils/printers/thermal_printer_port.dart';
import 'package:intl/intl.dart';
import 'package:restic_movil/app/data/models/order_combo_selection_model.dart';
import 'package:restic_movil/app/data/models/order_detail_model.dart';
import 'package:restic_movil/app/data/models/order_model.dart';
import 'package:restic_movil/core/utils/printers/printable_ticket.dart';
import 'package:restic_movil/core/utils/helpers/string_extensions.dart';

// Ticket de pedido/cocina para impresora de 80mm (48 chars por línea)
class OrderTicket80mm implements PrintableTicket {
  final OrderModel order;
  // Si se especifica, se imprimen solo estos detalles (para enrutamiento por categoria)
  final List<OrderDetailModel>? filteredDetails;

  OrderTicket80mm({required this.order, this.filteredDetails});

  static const String _sep = '------------------------------------------------'; // 48 chars

  @override
  Future<void> printReceipt(ThermalPrinterPort printer) async {
    final dateFormat = DateFormat('dd/MM/yyyy HH:mm');
    final String date = order.openingDate != null
        ? dateFormat.format(DateTime.parse(order.openingDate!))
        : dateFormat.format(DateTime.now());

    printer.printNewLine();
    printer.printCustom('PEDIDO', 3, 1);
    printer.printNewLine();

    // INFO DE LA ORDEN
    printer.printCustom('Orden: #${order.orderNumber}'.withoutDiacritics, 2, 0);
    printer.printCustom('Fecha: $date'.withoutDiacritics, 2, 0);
    if (order.createdBy != null) {
      printer.printCustom('Creado por: ${order.createdBy!.fullName}'.withoutDiacritics, 2, 0);
    }

    if (order.originType?.code == 'SALON') {
      final tables = order.tables?.map((e) => e.name).join(', ') ?? 'N/A';
      printer.printCustom('Mesas: $tables'.withoutDiacritics, 2, 0);
      if (order.customer != null) {
        printer.printCustom('Cliente: ${order.customer!.fullName}'.withoutDiacritics, 2, 0);
      }
    } else if (order.originType?.code == 'DELIVERY' ||
        order.originType?.code == 'TAKE_AWAY') {
      printer.printCustom('Cliente: ${order.customer?.fullName ?? 'N/A'}'.withoutDiacritics, 2, 0);
      if (order.customer?.address != null && order.customer!.address!.isNotEmpty) {
        printer.printCustom('Direccion: ${order.customer!.address}'.withoutDiacritics, 2, 0);
      }
      if (order.customer?.phone != null && order.customer!.phone!.isNotEmpty) {
        printer.printCustom('Telefono: ${order.customer!.phone}'.withoutDiacritics, 2, 0);
      }
    } else if (order.customer != null) {
      printer.printCustom('Cliente: ${order.customer!.fullName}'.withoutDiacritics, 2, 0);
    }

    if (order.observations != null && order.observations!.trim().isNotEmpty) {
      printer.printNewLine();
      printer.printCustom('OBSERVACION GENERAL:', 2, 1);
      printer.printCustom(order.observations!.withoutDiacritics, 1, 1);
      printer.printNewLine();
    }

    printer.printCustom(_sep, 1, 1);
    printer.printCustom('CANT.   PRODUCTO', 2, 0);
    printer.printCustom(_sep, 1, 1);

    final details = filteredDetails ?? order.details ?? [];
    for (var item in details) {
      // Parsear observations primero para poder incluir el acompañante en el nombre impreso.
      // Cubre el caso en que el backend devuelve solo el nombre base del producto (sin el "+Plato2").
      final String afterPrefix = (item.observations != null &&
              item.observations!.startsWith('COMBINADO: '))
          ? item.observations!.substring('COMBINADO: '.length)
          : '';
      final int sepIdx = afterPrefix.indexOf(' | ');
      final String companion = sepIdx >= 0
          ? afterPrefix.substring(0, sepIdx).trim()
          : afterPrefix.trim();
      final String comboNote = sepIdx >= 0
          ? afterPrefix.substring(sepIdx + 3).trim()
          : '';

      // Si el nombre base no contiene ya al acompañante, lo agrega para que siempre sea visible.
      final String baseName = item.sizeLabel != null
          ? '${item.productName ?? 'Producto'} - ${item.sizeLabel}'
          : (item.productName ?? 'Producto');
      final String pName = (companion.isNotEmpty && !baseName.contains(companion))
          ? '$baseName + $companion'
          : baseName;

      printer.printCustom('${item.quantity}x  $pName'.withoutDiacritics, 2, 0);

      if (item.comboSelections != null && item.comboSelections!.isNotEmpty) {
        _printComboSelections(printer, item.comboSelections!, item.quantity ?? 1, item.observations);
      }
      if (companion.isNotEmpty) {
        printer.printCustom('    [COMBINADO]'.withoutDiacritics, 1, 0);
        if (comboNote.isNotEmpty) {
          printer.printCustom('    [Nota: $comboNote]'.withoutDiacritics, 1, 0);
        }
      } else if (item.observations != null &&
                 item.observations!.trim().isNotEmpty &&
                 !item.observations!.startsWith('COMBO_NOTES:')) {
        printer.printCustom('    [Nota: ${item.observations}]'.withoutDiacritics, 1, 0);
      }
      printer.printNewLine();
    }

    printer.printCustom(_sep, 1, 1);
    printer.printCustom('Origen: ${order.originType?.description ?? 'N/A'}'.withoutDiacritics, 2, 0);
    printer.printNewLine();
    printer.printNewLine();
    printer.printNewLine();
    printer.paperCut();
  }

  /* imprime selecciones de combo agrupadas por unitIndex cuando hay más de una unidad */
  void _printComboSelections(
    ThermalPrinterPort printer,
    List<OrderComboSelectionModel> selections,
    int quantity,
    String? observations,
  ) {
    final bool hasUnitIndex = selections.any((s) => s.unitIndex != null);

    // Parsear notas por unidad si existe el formato COMBO_NOTES
    Map<int, String> unitNotes = {};
    if (observations != null && observations.startsWith('COMBO_NOTES:')) {
      final String notesStr = observations.substring('COMBO_NOTES:'.length);
      final List<String> parts = notesStr.split('|');
      for (final part in parts) {
        final RegExpMatch? match = RegExp(r'^\[(\d+)\]\s*(.*)$').firstMatch(part);
        if (match != null) {
          final int unitIdx = int.parse(match.group(1)!) - 1;
          final String note = match.group(2)!.trim();
          if (note.isNotEmpty) unitNotes[unitIdx] = note;
        }
      }
    }

    if (hasUnitIndex && quantity > 1) {
      final Map<int, List<String>> byUnit = {};
      for (final s in selections) {
        final int unit = s.unitIndex ?? 0;
        byUnit.putIfAbsent(unit, () => []).add(s.selectedProductName ?? 'Extra');
      }
      final List<int> sortedKeys = byUnit.keys.toList()..sort();
      for (final unit in sortedKeys) {
        printer.printCustom(
          '  [Combo ${unit + 1}]'.withoutDiacritics,
          1,
          0,
        );
        for (final name in byUnit[unit]!) {
          printer.printCustom(
            '   $name'.withoutDiacritics,
            1,
            0,
          );
        }
        if (unitNotes.containsKey(unit)) {
          printer.printCustom(
            '    [Nota: ${unitNotes[unit]}]'.withoutDiacritics,
            1,
            0,
          );
        }
      }
    } else {
      for (final combo in selections) {
        printer.printCustom(
          '    > ${combo.quantity ?? 1}x ${combo.selectedProductName ?? 'Extra'}'.withoutDiacritics,
          1,
          0,
        );
      }
    }
  }
}
