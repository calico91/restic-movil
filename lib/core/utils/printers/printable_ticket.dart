import 'package:blue_thermal_printer/blue_thermal_printer.dart';

abstract class PrintableTicket {
  /// Mtodo que se encargar de construir e imprimir la estructura del ticket
  /// utilizando la instancia de la impresora Bluetooth.
  Future<void> printReceipt(BlueThermalPrinter printer);
}
