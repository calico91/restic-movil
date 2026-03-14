import 'package:get/get.dart';
import 'package:blue_thermal_printer/blue_thermal_printer.dart';
import 'package:logger/logger.dart';
import 'package:restic_movil/core/utils/printers/printable_ticket.dart';

class PrinterService extends GetxService {
  final BlueThermalPrinter bluetooth = BlueThermalPrinter.instance;
  final Logger _logger = Logger();

  RxList<BluetoothDevice> devices = <BluetoothDevice>[].obs;
  Rx<BluetoothDevice?> selectedDevice = Rx<BluetoothDevice?>(null);
  RxBool isConnected = false.obs;

  @override
  void onInit() {
    super.onInit();
    initBluetooth();
  }

  /* inicializar bluetooth y escuchar estado */
  Future<void> initBluetooth() async {
    try {
      bool? isOn = await bluetooth.isOn;
      if (isOn == true) {
        await getDevices();
      }

      bluetooth.onStateChanged().listen((state) {
        switch (state) {
          case BlueThermalPrinter.CONNECTED:
            isConnected.value = true;
            _logger.i("Bluetooth Conectado");
            break;
          case BlueThermalPrinter.DISCONNECTED:
            isConnected.value = false;
            _logger.i("Bluetooth Desconectado");
            break;
          case BlueThermalPrinter.DISCONNECT_REQUESTED:
            isConnected.value = false;
            break;
          case BlueThermalPrinter.STATE_TURNING_OFF:
            isConnected.value = false;
            break;
          case BlueThermalPrinter.STATE_OFF:
            isConnected.value = false;
            break;
          case BlueThermalPrinter.STATE_ON:
            getDevices();
            break;
          default:
            break;
        }
      });
    } catch (e) {
      _logger.e("Error inicializando Bluetooth: $e");
    }
  }

  /* obtener lista de dispositivos vinculados */
  Future<void> getDevices() async {
    try {
      List<BluetoothDevice> pairedDevices = await bluetooth.getBondedDevices();
      devices.assignAll(pairedDevices);
    } catch (e) {
      _logger.e("Error obteniendo dispositivos: $e");
    }
  }

  /* conectar a un dispositivo especÃ­fico */
  Future<bool> connect(BluetoothDevice device) async {
    try {
      if (await bluetooth.isConnected == true) {
        await bluetooth.disconnect();
        isConnected.value = false;
      }
      await bluetooth.connect(device);
      selectedDevice.value = device;
      isConnected.value = true;
      return true;
    } catch (e) {
      _logger.e("Error conectando a impresora: $e");
      isConnected.value = false;
      return false;
    }
  }

  /* desconectar impresora */
  Future<void> disconnect() async {
    try {
      await bluetooth.disconnect();
      selectedDevice.value = null;
      isConnected.value = false;
    } catch (e) {
      _logger.e("Error desconectando impresora: $e");
    }
  }

  /* imprimir cualquier tipo de ticket */
  Future<void> printTicket(PrintableTicket ticket) async {
    if (await bluetooth.isConnected != true) {
      _logger.w("La impresora no está conectada");
      return;
    }

    try {
      await ticket.printReceipt(bluetooth);
    } catch (e) {
      _logger.e("Error imprimiendo: $e");
    }
  }
}
