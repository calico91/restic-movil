import 'package:blue_thermal_printer/blue_thermal_printer.dart';
import 'package:restic_movil/core/utils/printers/thermal_printer_port.dart';

/// Puerto Bluetooth que delega cada operación de impresión
/// a la instancia de [BlueThermalPrinter].
class BluetoothPrinterPort implements ThermalPrinterPort {
  final BlueThermalPrinter _printer;

  BluetoothPrinterPort(this._printer);

  @override
  void printNewLine() => _printer.printNewLine();

  @override
  void printCustom(String text, int size, int align) =>
      _printer.printCustom(text, size, align);

  @override
  void paperCut() => _printer.paperCut();
}
