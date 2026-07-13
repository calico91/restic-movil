---
name: ticket-impresion
description: "Crear tickets de impresión térmica (58mm y 80mm) implementando PrintableTicket y usando ThermalPrinterPort para restic-movil"
---

## Qué hace esta skill

Crea un nuevo formato de ticket de impresión térmica siguiendo el patrón del proyecto:
- Implementación de la interfaz `PrintableTicket`
- Uso de `ThermalPrinterPort` para comandos de impresión
- Versiones para 58mm (32 caracteres por línea) y 80mm (42 caracteres por línea)
- Soporte para enrutamiento por categoría con `filteredDetails`
- Uso de `StringExtensions.withoutDiacritics` para normalizar texto

## Archivos a crear

```
lib/core/utils/printers/tickets/<ancho>mm/<nombre_ticket>_<ancho>mm.dart
```

## Template para ticket 58mm

```dart
import 'package:intl/intl.dart';
import 'package:restic_movil/app/data/models/<modelo_orden>_model.dart';
import 'package:restic_movil/core/utils/printers/thermal_printer_port.dart';
import 'package:restic_movil/core/utils/printers/printable_ticket.dart';
import 'package:restic_movil/core/utils/helpers/string_extensions.dart';

class <NombreTicket>Ticket58mm implements PrintableTicket {
  final OrderModel order;
  final List<OrderDetailModel>? filteredDetails;

  <NombreTicket>Ticket58mm({required this.order, this.filteredDetails});

  static const String _sep = '--------------------------------'; // 32 chars

  @override
  Future<void> printReceipt(ThermalPrinterPort printer) async {
    final dateFormat = DateFormat('dd/MM/yyyy HH:mm');

    printer.printNewLine();
    printer.printCustom('<TITULO>', 3, 1);
    printer.printNewLine();

    // Información de la orden
    printer.printCustom('Orden: #${order.orderNumber}'.withoutDiacritics, 1, 0);
    printer.printCustom('Fecha: ${dateFormat.format(DateTime.now())}'.withoutDiacritics, 1, 0);

    printer.printCustom(_sep, 1, 1);
    printer.printCustom('DETALLE', 2, 0);
    printer.printCustom(_sep, 1, 1);

    final details = filteredDetails ?? order.details ?? [];
    for (var item in details) {
      printer.printCustom(
        '${item.quantity}x  ${item.productName ?? 'Producto'}'.withoutDiacritics,
        2,
        0,
      );
    }

    printer.printCustom(_sep, 1, 1);
    printer.printNewLine();
    printer.printNewLine();
    printer.paperCut();
  }
}
```

## Template para ticket 80mm

```dart
// Mismo patrón que 58mm pero con:
static const String _sep = '------------------------------------------'; // 42 chars
// Y printCustom con alineación ajustada para 80mm
```

## APIs de ThermalPrinterPort disponibles

| Método | Descripción |
|--------|-------------|
| `printCustom(String text, int size, int alignment)` | Imprime línea con tamaño (1-7) y alineación (0=izq, 1=centro, 2=der) |
| `printNewLine()` | Salto de línea |
| `paperCut()` | Corte de papel |
| `printImage(String path)` | Imagen (opcional) |

## Ejemplo del código real (OrderTicket58mm)

```dart
class OrderTicket58mm implements PrintableTicket {
  final OrderModel order;
  final List<OrderDetailModel>? filteredDetails;

  OrderTicket58mm({required this.order, this.filteredDetails});

  static const String _sep = '--------------------------------';

  @override
  Future<void> printReceipt(ThermalPrinterPort printer) async {
    final dateFormat = DateFormat('dd/MM/yyyy HH:mm');
    final String date = order.openingDate != null
        ? dateFormat.format(DateTime.parse(order.openingDate!))
        : dateFormat.format(DateTime.now());

    printer.printNewLine();
    printer.printCustom('PEDIDO', 3, 1);
    printer.printNewLine();

    printer.printCustom('Orden: #${order.orderNumber}'.withoutDiacritics, 1, 0);
    printer.printCustom('Fecha: $date'.withoutDiacritics, 1, 0);

    if (order.originType?.code == 'SALON') {
      final tables = order.tables?.map((e) => e.name).join(', ') ?? 'N/A';
      printer.printCustom('Mesas: $tables'.withoutDiacritics, 1, 0);
    }

    printer.printCustom(_sep, 1, 1);
    printer.printCustom('CANT.   PRODUCTO', 2, 0);
    printer.printCustom(_sep, 1, 1);

    final details = filteredDetails ?? order.details ?? [];
    for (var item in details) {
      printer.printCustom('${item.quantity}x  ${item.productName ?? 'Producto'}'.withoutDiacritics, 2, 0);
      printer.printNewLine();
    }

    printer.printCustom(_sep, 1, 1);
    printer.printNewLine();
    printer.printNewLine();
    printer.printNewLine();
    printer.paperCut();
  }
}
```

## Reglas importantes

1. **Siempre** llamar a `.withoutDiacritics` en textos con tildes/ñ antes de imprimir
2. 58mm = 32 caracteres por línea; 80mm = 42 caracteres por línea
3. Usar `filteredDetails` cuando el ticket se genera por enrutamiento de categoría
4. `paperCut()` debe ir al final del ticket
5. Los tamaños de fuente: 1=normal, 2=grande, 3=muy grande (bold)
6. Para combinaciones (combos), usar el helper `_printComboSelections` agrupando por `unitIndex`
7. Los tickets se almacenan en `core/utils/printers/tickets/<ancho>mm/`
