import 'dart:io';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:blue_thermal_printer/blue_thermal_printer.dart';
import 'package:logger/logger.dart';
import 'package:restic_movil/app/data/models/category_model.dart';
import 'package:restic_movil/app/data/models/network_printer_model.dart';
import 'package:restic_movil/app/data/models/order_detail_model.dart';
import 'package:restic_movil/app/data/models/order_item_model.dart';
import 'package:restic_movil/app/data/models/order_model.dart';
import 'package:restic_movil/app/data/models/printer_zone_model.dart';
import 'package:restic_movil/app/data/services/storage_service.dart';
import 'package:restic_movil/core/utils/enums/printer_connection_type.dart';
import 'package:restic_movil/core/utils/modals/modal_error.dart';
import 'package:restic_movil/core/utils/printers/bluetooth_printer_port.dart';
import 'package:restic_movil/core/utils/printers/category_printer_resolver.dart';
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

  // Zonas de impresion (persistencia local) y mapeo categoria->zona
  final RxList<PrinterZoneModel> zones = <PrinterZoneModel>[].obs;
  final RxMap<String, String> categoryZoneMappings = <String, String>{}.obs;

  @override
  void onInit() {
    super.onInit();
    WidgetsBinding.instance.addObserver(this);
    _loadPrinterSize();
    _loadZones();
    _loadCategoryZoneMappings();
    _initConnections();
  }

  /* inicializar conexiones en orden: red primero, Bluetooth después */
  Future<void> _initConnections() async {
    await _autoConnectNetwork();
    await initBluetooth();
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

  /* cargar zonas de impresion y mapeo categoria->zona desde storage local */
  Future<void> _loadZones() async {
    final List<PrinterZoneModel> stored =
        await _storageService.getPrinterZones();
    zones.assignAll(stored);
  }

  Future<void> _loadCategoryZoneMappings() async {
    final Map<String, String> stored =
        await _storageService.getCategoryZoneMappings();
    categoryZoneMappings.assignAll(stored);
  }

  /* persistir la lista de zonas custom (excluyendo Caja) */
  Future<void> persistZones() async {
    await _storageService.savePrinterZones(zones.toList());
  }

  /* asignar una categoria a una zona (o null para quitar la asignacion) */
  Future<void> setCategoryZoneMapping(
    String categoryId,
    String? zoneId,
  ) async {
    if (zoneId == null) {
      categoryZoneMappings.remove(categoryId);
    } else {
      categoryZoneMappings[categoryId] = zoneId;
    }
    await _storageService.saveCategoryZoneMappings(
      Map<String, String>.from(categoryZoneMappings),
    );
  }

  /* asignar varias categorias a una zona de forma masiva */
  Future<void> bulkSetCategoryZoneMapping(
    List<String> categoryIds,
    String zoneId,
  ) async {
    if (categoryIds.isEmpty) return;
    for (final String id in categoryIds) {
      if (zoneId == kCajaZoneId) {
        categoryZoneMappings[id] = kCajaZoneId;
      } else {
        categoryZoneMappings[id] = zoneId;
      }
    }
    await _storageService.saveCategoryZoneMappings(
      Map<String, String>.from(categoryZoneMappings),
    );
  }

  /* la zona "Caja" se deriva de la configuracion de red activa. */
  PrinterZoneModel? get cajaZone {
    final NetworkPrinterModel? cfg = networkConfig.value;
    if (cfg == null) return null;
    return PrinterZoneModel(
      id: kCajaZoneId,
      name: 'Caja',
      ip: cfg.ip,
      port: cfg.port,
      isCaja: true,
    );
  }

  /* lista combinada con Caja primero, seguida de las zonas custom */
  List<PrinterZoneModel> get allZones {
    final List<PrinterZoneModel> list = <PrinterZoneModel>[];
    final PrinterZoneModel? caja = cajaZone;
    if (caja != null) list.add(caja);
    list.addAll(zones);
    return list;
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
    // Si hay una conexión de red activa, desconectarla primero
    if (isNetworkConnected.value) {
      _logger.i('Desconectando impresora de red antes de conectar por Bluetooth...');
      await disconnectNetwork();
    }
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
    // Si la impresora de red ya está activa, no interferir con Bluetooth
    if (isNetworkConnected.value) {
      _logger.i('Conexión de red activa, omitiendo auto-conexión Bluetooth');
      return;
    }
    // Si el último tipo guardado fue red, respetar la preferencia del usuario
    final String? savedType = await _storageService.getConnectionType();
    if (savedType == 'network') {
      _logger.i('Tipo guardado es red, omitiendo auto-conexión Bluetooth');
      return;
    }
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

  /* conectar una impresora por red TCP: desconecta BT si está activo, prueba la conexión y persiste la configuración */
  Future<bool> connectNetwork(NetworkPrinterModel config) async {
    // Si hay una conexión Bluetooth activa, desconectarla primero
    if (isConnected.value) {
      _logger.i('Desconectando Bluetooth antes de conectar por red...');
      await disconnect();
    }
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
      await _storageService.saveNetworkPrinterIp(config.ip);
      await _storageService.saveNetworkPrinterPort(config.port);
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

  /* imprimir un ticket en una impresora de red especifica sin alterar la configuracion activa.
     Propaga el error para que el caller (printComandaMultiPrinter*) lo registre y muestre
     un dialogo resumen al usuario. */
  Future<void> printTicketToSpecificNetwork(
    PrintableTicket ticket,
    String ip,
    int port, {
    String? displayName,
  }) async {
    NetworkPrinterPort? printerPort;
    try {
      printerPort = await NetworkPrinterPort.connect(ip, port);
      await ticket.printReceipt(printerPort);
      await printerPort.close();
    } catch (e, st) {
      _logger.e('Error imprimiendo en impresora especifica $ip:$port — $e',
          stackTrace: st);
      try {
        await printerPort?.close();
      } catch (_) {}
      throw _PrintZoneError(
        displayName: displayName ?? '$ip:$port',
        ip: ip,
        port: port,
        cause: e,
      );
    }
  }

  /* imprimir una comanda distribuyendo items a cada impresora segun la categoria */
  Future<void> printComandaMultiPrinter({
    required OrderModel order,
    required List<OrderItemModel> sourceItems,
    required List<CategoryModel> categories,
    required PrintableTicket Function(OrderModel, List<OrderItemModel>) ticketBuilder,
  }) async {
    // Agrupar items por impresora destino segun la categoria del producto,
    // tomando en cuenta las zonas locales y el mapeo categoria->zona.
    final Map<NetworkPrinterModel?, List<OrderItemModel>> groups =
        CategoryPrinterResolver.groupItemsByPrinter(
      sourceItems,
      categories,
      zones: zones.toList(),
      mappings: Map<String, String>.from(categoryZoneMappings),
    );

    final List<_PrintZoneError> failures = <_PrintZoneError>[];

    for (final MapEntry<NetworkPrinterModel?, List<OrderItemModel>> entry in groups.entries) {
      final PrintableTicket ticket = ticketBuilder(order, entry.value);

      if (entry.key != null) {
        // Impresora especifica de categoria
        try {
          await printTicketToSpecificNetwork(
            ticket,
            entry.key!.ip,
            entry.key!.port,
            displayName: entry.key!.name,
          );
        } on _PrintZoneError catch (e) {
          failures.add(e);
        }
      } else {
        // Impresora por defecto
        try {
          await printTicket(ticket);
        } catch (_) {
          // El error en la impresora por defecto tambien se reporta.
          failures.add(_PrintZoneError(
            displayName: 'Impresora principal',
            ip: '',
            port: 0,
            cause: 'No se pudo imprimir en la impresora activa.',
          ));
        }
      }
    }

    if (failures.isNotEmpty) {
      _showPrintFailuresModal(failures);
    }
  }

  /* imprimir comandas de una orden existente distribuyendo por categoria (reimpresion) */
  Future<void> printComandaMultiPrinterFromDetails({
    required OrderModel order,
    required List<OrderDetailModel> details,
    required List<CategoryModel> categories,
    required PrintableTicket Function(OrderModel, List<OrderDetailModel>) ticketBuilder,
  }) async {
    // Agrupar detalles por impresora destino usando categoryId del backend,
    // tomando en cuenta las zonas locales y el mapeo categoria->zona.
    final Map<NetworkPrinterModel?, List<OrderDetailModel>> groups =
        CategoryPrinterResolver.groupDetailsByPrinter(
      details,
      categories,
      zones: zones.toList(),
      mappings: Map<String, String>.from(categoryZoneMappings),
    );

    final List<_PrintZoneError> failures = <_PrintZoneError>[];

    for (final MapEntry<NetworkPrinterModel?, List<OrderDetailModel>> entry in groups.entries) {
      final PrintableTicket ticket = ticketBuilder(order, entry.value);

      if (entry.key != null) {
        // Impresora especifica de categoria
        try {
          await printTicketToSpecificNetwork(
            ticket,
            entry.key!.ip,
            entry.key!.port,
            displayName: entry.key!.name,
          );
        } on _PrintZoneError catch (e) {
          failures.add(e);
        }
      } else {
        // Impresora por defecto
        try {
          await printTicket(ticket);
        } catch (_) {
          failures.add(_PrintZoneError(
            displayName: 'Impresora principal',
            ip: '',
            port: 0,
            cause: 'No se pudo imprimir en la impresora activa.',
          ));
        }
      }
    }

    if (failures.isNotEmpty) {
      _showPrintFailuresModal(failures);
    }
  }

  /* Mostrar un dialogo resumen con las impresoras que fallaron durante la
     impresion multi-zona. Las comandas que SI se imprimieron no se reintentan. */
  void _showPrintFailuresModal(List<_PrintZoneError> failures) {
    final String body = failures.map((f) => '- ${f.displayName}').join('\n');
    Get.dialog(
      ModalError(
        title: failures.length == 1
            ? 'No se pudo imprimir la comanda'
            : 'Algunas comandas no se imprimieron',
        message: 'Zonas con error de impresion:\n$body',
      ),
    );
  }
}

/// Excepcion interna usada para distinguir errores de impresion por zona
/// de cualquier otro fallo, y para que el caller muestre un mensaje claro.
class _PrintZoneError implements Exception {
  final String displayName;
  final String ip;
  final int port;
  final Object cause;

  _PrintZoneError({
    required this.displayName,
    required this.ip,
    required this.port,
    required this.cause,
  });

  @override
  String toString() => 'PrintZoneError($displayName @ $ip:$port): $cause';
}
