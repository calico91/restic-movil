import 'dart:convert';
import 'dart:io';
import 'package:restic_movil/core/utils/printers/thermal_printer_port.dart';

/// Puerto de red que envía comandos ESC/POS sobre TCP (puerto estándar 9100).
/// Abre una conexión TCP por cada trabajo de impresión.
class NetworkPrinterPort implements ThermalPrinterPort {
  final Socket _socket;

  NetworkPrinterPort(this._socket);

  /// Abre la conexión TCP con la impresora y retorna el puerto listo para imprimir.
  static Future<NetworkPrinterPort> connect(
    String ip,
    int port, {
    Duration timeout = const Duration(seconds: 5),
  }) async {
    final Socket socket = await Socket.connect(ip, port, timeout: timeout);
    return NetworkPrinterPort(socket);
  }

  void _send(List<int> bytes) => _socket.add(bytes);

  @override
  void printNewLine() => _send([0x0A]);

  @override
  void printCustom(String text, int size, int align) {
    // Alineación ESC a n  (0=izquierda, 1=centro, 2=derecha)
    _send([0x1B, 0x61, align.clamp(0, 2)]);

    // Tamaño GS ! n
    final int sizeByte;
    switch (size) {
      case 3:
        sizeByte = 0x11; // doble ancho + doble alto
        break;
      case 2:
        sizeByte = 0x10; // doble alto
        break;
      default:
        sizeByte = 0x00; // normal
    }
    _send([0x1D, 0x21, sizeByte]);

    // Texto en Latin-1 (ASCII extendido) + salto de línea
    _send([...latin1.encode(text), 0x0A]);
  }

  @override
  void paperCut() => _send([0x1D, 0x56, 0x42, 0x00]); // GS V B 0 – corte parcial

  /// Vacía el buffer de escritura y cierra el socket.
  Future<void> close() async {
    await _socket.flush();
    await _socket.close();
  }
}
