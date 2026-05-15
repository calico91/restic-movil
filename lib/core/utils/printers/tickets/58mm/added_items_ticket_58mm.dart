import 'package:restic_movil/core/utils/printers/thermal_printer_port.dart';
import 'package:intl/intl.dart';
import 'package:restic_movil/app/data/models/order_model.dart';
import 'package:restic_movil/app/data/models/order_item_model.dart';
import 'package:restic_movil/core/utils/printers/printable_ticket.dart';
import 'package:restic_movil/core/utils/helpers/string_extensions.dart';

// Ticket de productos adicionales agregados a un pedido existente (58mm, 32 chars por linea)
class AddedItemsTicket58mm implements PrintableTicket {
  final OrderModel order;
  final List<OrderItemModel> items;

  AddedItemsTicket58mm({required this.order, required this.items});

  static const String _sep = '--------------------------------'; // 32 chars

  @override
  Future<void> printReceipt(ThermalPrinterPort printer) async {
    final String date = DateFormat('dd/MM/yyyy HH:mm').format(DateTime.now());

    printer.printNewLine();
    printer.printCustom('ADICIONAL', 3, 1);
    printer.printNewLine();

    printer.printCustom('Orden: #${order.orderNumber}'.withoutDiacritics, 1, 0);
    printer.printCustom('Fecha: $date'.withoutDiacritics, 1, 0);
    if (order.createdBy != null) {
      printer.printCustom('Creado por: ${order.createdBy!.fullName}'.withoutDiacritics, 1, 0);
    }
    if (order.tables != null && order.tables!.isNotEmpty) {
      final String tableNames = order.tables!.map((e) => e.name).join(', ');
      printer.printCustom('Mesas: $tableNames'.withoutDiacritics, 1, 0);
    }

    printer.printCustom(_sep, 1, 1);
    printer.printCustom('CANT.   PRODUCTO', 2, 0);
    printer.printCustom(_sep, 1, 1);

    for (final OrderItemModel item in items) {
      // Para COMBINADO efectivamente combinado: mostrar "P1 + P2"; si es individual, solo el nombre base
      final String displayName = item.combinedWith != null
          ? '${item.productName} + ${item.combinedWith!.name ?? ""}'
          : item.productName;

      printer.printCustom('${item.quantity}x  $displayName'.withoutDiacritics, 2, 0);

      if (item.comboSelections != null && item.comboSelections!.isNotEmpty) {
        _printComboSelections(printer, item.comboSelections!, item.quantity);
      }

      // Mostrar [COMBINADO] solo cuando hay acompañante real + nota si la hay
      if (item.combinedWith != null) {
        printer.printCustom('    [COMBINADO]'.withoutDiacritics, 1, 0);
        if (item.comment != null && item.comment!.isNotEmpty) {
          printer.printCustom('    [Nota: ${item.comment}]'.withoutDiacritics, 1, 0);
        }
      } else if (item.comment != null && item.comment!.trim().isNotEmpty) {
        printer.printCustom('    [Nota: ${item.comment}]'.withoutDiacritics, 1, 0);
      }

      printer.printNewLine();
    }

    printer.printCustom(_sep, 1, 1);
    printer.printNewLine();
    printer.printNewLine();
    printer.printNewLine();
    printer.paperCut();
  }

  /* imprime selecciones de combo agrupadas por unidad cuando hay más de una */
  void _printComboSelections(
    ThermalPrinterPort printer,
    List<Map<String, String>> selections,
    int quantity,
  ) {
    final bool hasUnitIndex = selections.any((s) => s.containsKey('unitIndex'));
    if (hasUnitIndex && quantity > 1) {
      // Agrupar por unitIndex
      final Map<int, List<String>> byUnit = {};
      for (final s in selections) {
        final int unit = int.tryParse(s['unitIndex'] ?? '0') ?? 0;
        byUnit.putIfAbsent(unit, () => []).add(s['selectedProductName'] ?? 'Extra');
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
      }
    } else {
      for (final combo in selections) {
        final String name = combo['selectedProductName'] ?? 'Extra';
        final String qty = combo['quantity'] ?? '1';
        printer.printCustom(
          '    > ${qty}x $name'.withoutDiacritics,
          1,
          0,
        );
      }
    }
  }
}
