import 'package:get/get.dart';
import 'package:blue_thermal_printer/blue_thermal_printer.dart';
import 'package:logger/logger.dart';
import 'package:restic_movil/app/data/models/order_model.dart';
import 'package:restic_movil/core/utils/formatters/currency_formatter.dart';
import 'package:intl/intl.dart';

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

  /* conectar a un dispositivo específico */
  Future<bool> connect(BluetoothDevice device) async {
    try {
      if (await bluetooth.isConnected == true) {
        await bluetooth.disconnect();
      }
      await bluetooth.connect(device);
      selectedDevice.value = device;
      return true;
    } catch (e) {
      _logger.e("Error conectando a impresora: $e");
      return false;
    }
  }

  /* desconectar impresora */
  Future<void> disconnect() async {
    try {
      await bluetooth.disconnect();
      selectedDevice.value = null;
    } catch (e) {
      _logger.e("Error desconectando impresora: $e");
    }
  }

  /* imprimir ticket de la orden */
  Future<void> printReceipt(OrderModel order) async {
    if (await bluetooth.isConnected != true) {
      _logger.w("La impresora no está conectada");
      return;
    }

    try {
      final dateFormat = DateFormat('dd/MM/yyyy HH:mm');
      final String date = order.openingDate != null
          ? dateFormat.format(DateTime.parse(order.openingDate!))
          : dateFormat.format(DateTime.now());

      // ENCABEZADO
      bluetooth.printNewLine();
      bluetooth.printCustom("RESTIC MOVIL", 3, 1);
      bluetooth.printNewLine();
      bluetooth.printCustom("Comprobante de Venta", 1, 1);
      bluetooth.printNewLine();

      // INFO DE LA ORDEN
      bluetooth.printLeftRight("Orden: #${order.orderNumber}", "Fecha: $date", 1);
      
      String originLabel = "Origen: ${order.originType ?? 'N/A'}";
      if (order.originType == 'SALON' || order.originType == 'MESA') {
        final tables = order.tables?.map((e) => e.name).join(', ') ?? 'N/A';
        originLabel = "Mesa: $tables";
      } else if (order.customerName != null) {
        originLabel = "Cliente: ${order.customerName}";
      }
      
      bluetooth.printCustom(originLabel, 1, 0);
      bluetooth.printCustom("--------------------------------", 1, 1);

      // PRODUCTOS
      bluetooth.printLeftRight("Producto", "Subtotal", 1, format: "%-20s %10s %n");
      bluetooth.printCustom("--------------------------------", 1, 1);

      final details = order.details ?? [];
      for (var item in details) {
        String itemName = "${item.quantity}x ${item.productName ?? 'P.'}";
        if (itemName.length > 20) {
          itemName = itemName.substring(0, 19);
        }
        String itemTotal = CurrencyFormatter.toCurrency(item.subtotal ?? 0);
        
        bluetooth.printLeftRight(itemName, itemTotal, 1);
      }
      
      bluetooth.printCustom("--------------------------------", 1, 1);

      // TOTALES
      final totalStr = CurrencyFormatter.toCurrency(order.total ?? 0);
      bluetooth.printLeftRight("TOTAL:", totalStr, 2);
      bluetooth.printNewLine();
      
      // PIE DE PÁGINA
      bluetooth.printCustom("¡Gracias por su compra!", 1, 1);
      bluetooth.printNewLine();
      bluetooth.printNewLine();
      bluetooth.printNewLine();
      
      // CORTAR PAPEL Y ABRIR CAJA (Dependiendo de la impresora)
      bluetooth.paperCut();
    } catch (e) {
      _logger.e("Error imprimiendo: $e");
    }
  }
}
