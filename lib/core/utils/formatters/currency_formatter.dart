import 'package:intl/intl.dart';

class CurrencyFormatter {
  static final NumberFormat format = NumberFormat.currency(
    locale: 'es_CO',
    symbol: '\$',
    decimalDigits: 0,
    customPattern: '\$ #,##0',
  );

  /// Convierte cualquier numero (double, int, num) a un formato de moneda sin decimales
  /// Ejemplo: 35000 -> $ 35.000
  static String toCurrency(dynamic amount) {
    if (amount == null) return format.format(0);
    if (amount is String) {
      final parsed = double.tryParse(amount);
      return format.format(parsed ?? 0);
    }
    return format.format(amount);
  }
}
