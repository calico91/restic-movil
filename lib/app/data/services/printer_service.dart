import 'dart:io';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:blue_thermal_printer/blue_thermal_printer.dart';
import 'package:logger/logger.dart';
import 'package:restic_movil/app/data/models/network_printer_model.dart';
import 'package:restic_movil/app/data/services/storage_service.dart';
import 'package:restic_movil/core/utils/enums/printer_connection_type.dart';
import 'package:restic_movil/core/utils/printers/bluetooth_printer_port.dart';
import 'package:restic_movil/core/utils/printers/network_printer_port.dart';
import 'package:restic_movil/core/utils/printers/printable_ticket.dart';

class PrinterService extends GetxService with WidgetsBindingObserver {
  final BlueThermalPrinter bluetooth = BlueThermalPrinter.instance;
  final Logger _logger = Logger();
  final StorageService _storageService = Get.find<StorageService>();

  RxList<BluetoothDevice> devices = <BluetoothDevice>[].obs;
  Rx<BluetoothDevice?> selectedDevice = Rx<BluetoothDevice?>(null);
  RxBool isConnected = false.obs;
  RxBool isBluetoothOn = false.obs;
  RxString printerSize = '58mm'.obs;

  // Estado de impresora de red
  Rx<NetworkPrinterModel?> networkConfig = Rx<NetworkPrinterModel?>(null);
  RxBool isNetworkConnected = false.obs;
  Rx<PrinterConnectionType> connectionType =
      PrinterConnectionType.bluetooth.obs;

  @override
  void onInit() {
    super.onInit();
    WidgetsBinding.instance.addObserver(this);
    _loadPrinterSize();
    initBluetooth();
    _autoConnectNetwork();
  }

  @override
  void onClose() {
    WidgetsBinding.instance.removeObserver(this);
    super.onClose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _checkBluetoothState();
    }
  }

  /* cargar el tamaño de impresora guardado desde storage */
  Future<void> _loadPrinterSize() async {
    printerSize.value = await _storageService.getPrinterSize();
  }

  /* actualizar el tamaño de impresora y persistirlo */
  Future<void> setPrinterSize(String size) async {
    await _storageService.savePrinterSize(size);
    printerSize.value = size;
  }

  /* verifica el estado actual del bluetooth al volver a la app */  Future<void> _checkBluetoothState() async {
    try {
      bool? isOn = await bluetooth.isOn;
      isBluetoothOn.value = isOn == true;

      if (isOn != true) {
        isConnected.value = false;
        try {
          await bluetooth.disconnect();
        } catch (_) {}
      } else {
        bool? isConn = await bluetooth.isConnected;
        isConnected.value = isConn == true;

        if (devices.isEmpty) {
          await getDevices();
        }
      }
    } catch (e) {
      _logger.e("Error revisando estado Bluetooth: $e");
    }
  }

  /* inicializar bluetooth y escuchar estado */
  Future<void> initBluetooth() async {
    try {
      bool? isOn = await bluetooth.isOn;
      isBluetoothOn.value = isOn == true;

      if (isOn == true) {
        await getDevices();

        // Intentar conectar con la impresora guardada
        await autoConnect();
      }

      bluetooth.onStateChanged().listen((state) async {
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
            isBluetoothOn.value = false;
            try {
              await bluetooth.disconnect();
            } catch (_) {}
            break;
          case BlueThermalPrinter.STATE_OFF:
            isConnected.value = false;
            isBluetoothOn.value = false;
            try {
              await bluetooth.disconnect();
            } catch (_) {}
            break;
          case BlueThermalPrinter.STATE_ON:
            isBluetoothOn.value = true;
            // No hacemos disconnect() porque podríamos interrumpir el autoConnect
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
      if (device.name != null && device.address != null) {
        await _storageService.savePrinterDevice(device.name!, device.address!);
      }
      return true;
    } catch (e) {
      _logger.e("Error conectando a impresora: $e");
      isConnected.value = false;
      return false;
    }
  }

  /* reconexión automática de la impresora Bluetooth guardada */
  Future<void> autoConnect() async {
    try {
      final savedPrinter = await _storageService.getPrinterDevice();
      if (savedPrinter != null && savedPrinter['address'] != null) {
        final savedAddress = savedPrinter['address']!;
        final device = devices.firstWhereOrNull(
          (d) => d.address == savedAddress,
        );
        if (device != null) {
          _logger.i("Intentando auto-conectar a la impresora guardada...");
          
          // Desconexión preventiva para limpiar sockets fantasmas
          try {
            await bluetooth.disconnect();
          } catch (_) {}
          
          // Pausa antes de conectar
          await Future.delayed(const Duration(milliseconds: 500));
          
          bool success = await connect(device);
          
          // Reintento en caso de fallo  
          if (!success) {
            _logger.w("Primer intento fallido, reintentando tras 1 seg...");
            await Future.delayed(const Duration(seconds: 1));
            
            // Intento final limpieza agresiva
            try {
              await bluetooth.disconnect();
            } catch (_) {}
            await Future.delayed(const Duration(milliseconds: 300));
            
            await connect(device);
          }
        }
      }
    } catch (e) {
      _logger.e("Error en reconexión automática: $e");
    }
  }

  /* desconectar impresora */
  Future<void> disconnect() async {
    // Actualización inmediata para asegurar que la UI refleje el nuevo estado
    isConnected.value = false;
    selectedDevice.value = null;

    try {
      await bluetooth.disconnect();
    } catch (e) {
      _logger.e("Error desconectando impresora: $e");
    }
  }

  /* imprimir cualquier tipo de ticket despachando al puerto activo (Bluetooth o Red) */
  Future<void> printTicket(PrintableTicket ticket) async {
    if (connectionType.value == PrinterConnectionType.network) {
      final config = networkConfig.value;
      if (config == null) {
        _logger.w('No hay configuración de impresora de red');
        return;
      }
      NetworkPrinterPort? port;
      try {
        port = await NetworkPrinterPort.connect(config.ip, config.port);
        await ticket.printReceipt(port);
        await port.close();
      } catch (e) {
        _logger.e('Error imprimiendo por red: $e');
        isNetworkConnected.value = false;
        try {
          await port?.close();
        } catch (_) {}
      }
    } else {
      if (await bluetooth.isConnected != true) {
        _logger.w('La impresora Bluetooth no está conectada');
        isConnected.value = false;
        return;
      }
      try {
        final BluetoothPrinterPort port = BluetoothPrinterPort(bluetooth);
        await ticket.printReceipt(port);
      } catch (e) {
        _logger.e('Error imprimiendo: $e');
        isConnected.value = false;
        try {
          await bluetooth.disconnect();
        } catch (_) {}
      }
    }
  }

  /* conectar una impresora por red TCP: prueba la conexión y persiste la configuración */
  Future<bool> connectNetwork(NetworkPrinterModel config) async {
    try {
      final Socket socket = await Socket.connect(
        config.ip,
        config.port,
        timeout: const Duration(seconds: 5),
      );
      await socket.close();
      networkConfig.value = config;
      isNetworkConnected.value = true;
      connectionType.value = PrinterConnectionType.network;
      await _storageService.saveNetworkPrinter(config);
      await _storageService.saveConnectionType('network');
      _logger.i('Impresora de red conectada: ${config.ip}:${config.port}');
      return true;
    } catch (e) {
      _logger.e('Error conectando impresora de red: $e');
      isNetworkConnected.value = false;
      return false;
    }
  }

  /* desconectar la impresora de red y restaurar Bluetooth como transporte activo */
  Future<void> disconnectNetwork() async {
    isNetworkConnected.value = false;
    networkConfig.value = null;
    connectionType.value = PrinterConnectionType.bluetooth;
    await _storageService.saveConnectionType('bluetooth');
  }

  /* reconexión automática de la impresora de red guardada al iniciar la app */
  Future<void> _autoConnectNetwork() async {
    try {
      final String? savedType = await _storageService.getConnectionType();
      if (savedType == 'network') {
        final NetworkPrinterModel? saved =
            await _storageService.getNetworkPrinter();
        if (saved != null) {
          final Socket socket = await Socket.connect(
            saved.ip,
            saved.port,
            timeout: const Duration(seconds: 3),
          );
          await socket.close();
          networkConfig.value = saved;
          isNetworkConnected.value = true;
          connectionType.value = PrinterConnectionType.network;
          _logger.i('Auto-conexión de red exitosa: ${saved.ip}:${saved.port}');
        }
      }
    } catch (e) {
      _logger.e('Error en auto-conexión de red: $e');
      isNetworkConnected.value = false;
    }
  }

  /* imprimir página de prueba para verificar la conexión activa */
  Future<void> printTestPage() async {
    if (connectionType.value == PrinterConnectionType.network) {
      final config = networkConfig.value;
      if (config == null) throw Exception('Sin configuración de red');
      NetworkPrinterPort? port;
      try {
        port = await NetworkPrinterPort.connect(config.ip, config.port);
        port.printNewLine();
        port.printCustom('PRUEBA DE IMPRESION', 3, 1);
        port.printNewLine();
        port.printCustom('Impresora de red OK', 1, 1);
        port.printCustom('${config.ip}:${config.port}', 1, 1);
        port.printNewLine();
        port.printCustom('--------------------------------', 1, 1);
        port.printNewLine();
        port.printNewLine();
        port.printNewLine();
        port.paperCut();
        await port.close();
      } catch (e) {
        try {
          await port?.close();
        } catch (_) {}
        rethrow;
      }
    } else {
      if (await bluetooth.isConnected != true) {
        throw Exception('La impresora Bluetooth no está conectada');
      }
      final BluetoothPrinterPort port = BluetoothPrinterPort(bluetooth);
      port.printNewLine();
      port.printCustom('PRUEBA DE IMPRESION', 3, 1);
      port.printNewLine();
      port.printCustom('Impresora Bluetooth OK', 1, 1);
      if (selectedDevice.value?.name != null) {
        port.printCustom(selectedDevice.value!.name!, 1, 1);
      }
      port.printNewLine();
      port.printCustom('--------------------------------', 1, 1);
      port.printNewLine();
      port.printNewLine();
      port.printNewLine();
      port.paperCut();
    }
  }
}
