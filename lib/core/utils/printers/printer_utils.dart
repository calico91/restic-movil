import 'package:blue_thermal_printer/blue_thermal_printer.dart';
import 'package:intl/intl.dart';
import 'package:restic_movil/core/utils/helpers/string_extensions.dart';
import 'package:restic_movil/app/data/models/order_surcharge_model.dart';

class PrinterUtils {
  /// Formatea un monto de manera segura en Dólares/Pesos (Ej: $10,000) 
  /// y elimina caracteres especiales o diacríticos que puedan generar errores en la impresora térmica, como espacios no separables (NBSP).
  static String formatCurrency(double amount) {
    final currencyFormat = NumberFormat.currency(
      locale: 'en_US',
      symbol: '\$',
      decimalDigits: 0,
    );
    return currencyFormat.format(amount).replaceAll(RegExp(r'[^\x20-\x7E]'), '');
  }

  /// Imprime una fila con una etiqueta a la izquierda y un valor de moneda formateado a la derecha. (Utiliza printCustom size y align:2 que significa a la derecha)
  static void printCurrencyRow(BlueThermalPrinter printer, String label, double amount, int size) {
    // Pad fijo por defecto para mantener consistencia que se requería en precount (padLeft 12 por defecto a la hora de alinear si es necesario, pero alineacion genérica a la derecha maneja bien el margin).
    String formattedAmount = formatCurrency(amount).padLeft(12);
    printer.printCustom("$label$formattedAmount".withoutDiacritics, size, 2);
  }

  /// Imprime de forma estandarizada los cargos adicionales (surcharges) de una orden.
  static void printSurcharges(BlueThermalPrinter printer, List<OrderSurchargeModel>? surcharges) {
    if (surcharges == null || surcharges.isEmpty) return;
    
    for (var surcharge in surcharges) {
      String desc = surcharge.description.withoutDiacritics;
      if (desc.length > 15) desc = desc.substring(0, 15);
      // El padRight en 16 mantiene el espaciado estándar que usan los tickets ("Subtotal:       ")
      printCurrencyRow(printer, "$desc:".padRight(16), surcharge.amount, 1);
    }
  }
}
