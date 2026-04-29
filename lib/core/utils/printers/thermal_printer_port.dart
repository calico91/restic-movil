/// Puerto abstracto de impresora térmica.
/// Abstrae el transporte (Bluetooth o Red TCP) para que los tickets
/// de impresión sean independientes del medio de comunicación.
abstract class ThermalPrinterPort {
  void printNewLine();
  void printCustom(String text, int size, int align);
  void paperCut();
}
