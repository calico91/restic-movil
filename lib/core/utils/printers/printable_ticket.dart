import 'package:restic_movil/core/utils/printers/thermal_printer_port.dart';

abstract class PrintableTicket {
  /// Construye e imprime la estructura del ticket usando el puerto de impresora activo
  /// (Bluetooth o Red TCP), abstrayendo el medio de comunicación.
  Future<void> printReceipt(ThermalPrinterPort printer);
}
