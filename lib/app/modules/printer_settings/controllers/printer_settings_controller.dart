import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:blue_thermal_printer/blue_thermal_printer.dart';
import 'package:restic_movil/app/data/models/category_model.dart';
import 'package:restic_movil/app/data/models/network_printer_model.dart';
import 'package:restic_movil/app/data/models/printer_zone_model.dart';
import 'package:restic_movil/app/data/repositories/categories_repository.dart';
import 'package:restic_movil/app/data/services/printer_service.dart';
import 'package:restic_movil/core/utils/animations/loading_charging.dart';
import 'package:restic_movil/core/utils/enums/printer_connection_type.dart';
import 'package:restic_movil/core/utils/modals/modal_info.dart';
import 'package:restic_movil/core/utils/helpers/error_handler.dart';
import 'package:restic_movil/core/utils/modals/modal_error.dart';
import 'package:restic_movil/core/utils/printers/category_printer_resolver.dart';
import 'package:restic_movil/core/utils/snackbars/info_snackbar.dart';
import 'package:restic_movil/core/utils/validators/ip_validator.dart';

class PrinterSettingsController extends GetxController {
  final PrinterService printerService = Get.find<PrinterService>();
  final CategoriesRepository _categoriesRepository = Get.find<CategoriesRepository>();

  // Estado Bluetooth
  RxBool get isConnected => printerService.isConnected;
  RxBool get isBluetoothOn => printerService.isBluetoothOn;
  RxList<BluetoothDevice> get devices => printerService.devices;
  Rx<BluetoothDevice?> get selectedDevice => printerService.selectedDevice;

  // Estado de red
  Rx<NetworkPrinterModel?> get networkConfig => printerService.networkConfig;
  RxBool get isNetworkConnected => printerService.isNetworkConnected;
  Rx<PrinterConnectionType> get connectionType => printerService.connectionType;

  // Campos de formulario para conexión de red por defecto
  final TextEditingController ipController = TextEditingController();
  final TextEditingController portController =
      TextEditingController(text: '9100');

  final RxString selectedPrinterSize = '58mm'.obs;

  // Categorias con su configuracion de zona
  final RxList<CategoryModel> categories = <CategoryModel>[].obs;
  final RxBool isLoadingCategories = false.obs;

  // Zonas de impresion (custom + Caja)
  RxList<PrinterZoneModel> get zones => printerService.zones;
  RxMap<String, String> get categoryZoneMappings =>
      printerService.categoryZoneMappings;

  // Seleccion para asignacion masiva
  final RxSet<String> selectedCategoryIds = <String>{}.obs;

  @override
  void onInit() {
    super.onInit();
    scanDevices();
    _loadPrinterSize();
    _populateNetworkFields();
    _loadCategories();
  }

  @override
  void onClose() {
    ipController.dispose();
    portController.dispose();
    super.onClose();
  }

  /* cargar el tamaño de impresora guardado desde el secure storage */
  Future<void> _loadPrinterSize() async {
    selectedPrinterSize.value = printerService.printerSize.value;
  }

  /* pre-cargar IP y puerto si ya existe una impresora de red configurada */
  void _populateNetworkFields() {
    final config = printerService.networkConfig.value;
    if (config != null) {
      ipController.text = config.ip;
      portController.text = config.port.toString();
    }
  }

  /* guardar el tamaño de impresora seleccionado en el secure storage */
  Future<void> setPrinterSize(String size) async {
    await printerService.setPrinterSize(size);
    selectedPrinterSize.value = size;
  }

  /* escanear dispositivos bluetooth vinculados */
  Future<void> scanDevices() async {
    await printerService.getDevices();
  }

  /* conectar a la impresora Bluetooth seleccionada */
  Future<void> connect(BluetoothDevice device) async {
    Get.showOverlay(
      asyncFunction: () async {
        final bool success = await printerService.connect(device);
        if (success) {
          Get.dialog(
            ModalInfo(
              title: 'Éxito',
              message: 'Conectado a ${device.name}',
              icon: Icons.check_circle_outline,
              iconColor: Colors.green,
            ),
          );
        } else {
          ErrorHandler.showErrorDialog('No se pudo conectar a ${device.name}');
        }
      },
      loadingWidget: const LoadingCharging(),
    );
  }

  /* desconectar la impresora Bluetooth actual */
  Future<void> disconnect() async {
    Get.showOverlay(
      asyncFunction: () async {
        await printerService.disconnect();
        Get.showSnackbar(
          const InfoSnackbar('Impresora Bluetooth desconectada'),
        );
      },
      loadingWidget: const LoadingCharging(),
    );
  }

  /* conectar una impresora de red usando los campos IP y Puerto del formulario */
  Future<void> connectNetwork() async {
    final String ip = ipController.text.trim();
    final String portText = portController.text.trim();
    final int? port = int.tryParse(portText);

    if (port == null || port < 1 || port > 65535) {
      Get.dialog(
        const ModalError(
          title: 'Puerto inválido',
          message: 'El puerto debe estar entre 1 y 65535.\n\nEjemplo: 9100',
        ),
      );
      return;
    }

    final String? ipError = IpValidator.validate(ip);
    if (ipError != null) {
      Get.dialog(
        ModalError(
          title: 'IP inválida',
          message: ipError,
        ),
      );
      return;
    }

    Get.showOverlay(
      asyncFunction: () async {
        final config = NetworkPrinterModel(name: ip, ip: ip, port: port);
        final bool success = await printerService.connectNetwork(config);
        if (success) {
          Get.dialog(
            ModalInfo(
              title: 'Éxito',
              message: 'Conectado a $ip:$port',
              icon: Icons.check_circle_outline,
              iconColor: Colors.green,
            ),
          );
        } else {
          ErrorHandler.showErrorDialog('No se pudo conectar a $ip:$port');
        }
      },
      loadingWidget: const LoadingCharging(),
    );
  }

  /* desconectar la impresora de red y volver a Bluetooth como transporte */
  Future<void> disconnectNetwork() async {
    Get.showOverlay(
      asyncFunction: () async {
        await printerService.disconnectNetwork();
        Get.showSnackbar(
          const InfoSnackbar('Impresora de red desconectada'),
        );
      },
      loadingWidget: const LoadingCharging(),
    );
  }

  /* imprimir una página de prueba para verificar la conexión activa */
  Future<void> printTestPage() async {
    Get.showOverlay(
      asyncFunction: () async {
        try {
          await printerService.printTestPage();
          Get.showSnackbar(
            const InfoSnackbar('Página de prueba enviada a la impresora'),
          );
        } catch (e) {
          ErrorHandler.showErrorDialog(e);
        }
      },
      loadingWidget: const LoadingCharging(),
    );
  }

  /* cargar todas las categorias de la sucursal */
  Future<void> _loadCategories() async {
    isLoadingCategories.value = true;
    try {
      final List<CategoryModel> result = await _categoriesRepository.getCategories();
      categories.assignAll(result);
    } catch (e) {
      ErrorHandler.showErrorDialog('Error al cargar categorías');
    } finally {
      isLoadingCategories.value = false;
    }
  }

  // ───────────────────────────────────────────────
  //  Zonas de impresión
  // ───────────────────────────────────────────────

  PrinterZoneModel? get cajaZone => printerService.cajaZone;

  List<PrinterZoneModel> get allZones => printerService.allZones;

  /* agregar una zona custom. Devuelve true si se creó. */
  Future<bool> addZone({
    required String name,
    required String ip,
    required int port,
  }) async {
    final String trimmedName = name.trim();
    final String trimmedIp = ip.trim();
    if (trimmedName.isEmpty) {
      ErrorHandler.showErrorDialog('Ingresa un nombre para la zona');
      return false;
    }
    final String? ipError = IpValidator.validate(trimmedIp);
    if (ipError != null) {
      Get.dialog(
        ModalError(
          title: 'IP inválida',
          message: ipError,
        ),
      );
      return false;
    }
    if (port < 1 || port > 65535) {
      ErrorHandler.showErrorDialog('Ingresa un puerto válido (1-65535)');
      return false;
    }

    final String id = 'zone_${DateTime.now().microsecondsSinceEpoch}';
    final PrinterZoneModel zone = PrinterZoneModel(
      id: id,
      name: trimmedName,
      ip: trimmedIp,
      port: port,
    );
    zones.add(zone);
    await printerService.persistZones();
    return true;
  }

  /* actualizar una zona custom */
  Future<bool> updateZone({
    required String zoneId,
    required String name,
    required String ip,
    required int port,
  }) async {
    final int idx = zones.indexWhere((z) => z.id == zoneId);
    if (idx == -1) {
      ErrorHandler.showErrorDialog('Zona no encontrada');
      return false;
    }
    final String trimmedName = name.trim();
    final String trimmedIp = ip.trim();
    if (trimmedName.isEmpty) {
      ErrorHandler.showErrorDialog('El nombre es obligatorio');
      return false;
    }
    final String? ipError = IpValidator.validate(trimmedIp);
    if (ipError != null) {
      Get.dialog(
        ModalError(
          title: 'IP inválida',
          message: ipError,
        ),
      );
      return false;
    }
    if (port < 1 || port > 65535) {
      ErrorHandler.showErrorDialog('Puerto inválido (1-65535)');
      return false;
    }
    zones[idx] = zones[idx].copyWith(
      name: trimmedName,
      ip: trimmedIp,
      port: port,
    );
    await printerService.persistZones();
    return true;
  }

  /* eliminar una zona custom. Las asignaciones de categoria vuelven a Caja. */
  Future<bool> deleteZone(String zoneId) async {
    final PrinterZoneModel? zone =
        zones.firstWhereOrNull((z) => z.id == zoneId);
    if (zone == null) {
      ErrorHandler.showErrorDialog('Zona no encontrada');
      return false;
    }
    zones.removeWhere((z) => z.id == zoneId);
    // Reasignar categorias que usaban esta zona a Caja
    final List<String> affected = categoryZoneMappings.entries
        .where((e) => e.value == zoneId)
        .map((e) => e.key)
        .toList();
    for (final String catId in affected) {
      categoryZoneMappings[catId] = kCajaZoneId;
    }
    await printerService.persistZones();
    await printerService.bulkSetCategoryZoneMapping(affected, kCajaZoneId);
    return true;
  }

  // ───────────────────────────────────────────────
  //  Asignacion de categorias a zonas
  // ───────────────────────────────────────────────

  /* obtener la zona asignada a una categoria (o Caja por defecto) */
  String zoneIdForCategory(String categoryId) {
    return categoryZoneMappings[categoryId] ?? kCajaZoneId;
  }

  String zoneNameForCategory(String categoryId) {
    final String zoneId = zoneIdForCategory(categoryId);
    if (zoneId == kCajaZoneId) {
      return printerService.cajaZone != null ? 'Caja' : 'Sin asignar';
    }
    final PrinterZoneModel? z =
        zones.firstWhereOrNull((z) => z.id == zoneId);
    return z?.name ?? 'Sin asignar';
  }

  /* asignar una categoria individual a una zona */
  Future<void> assignCategoryToZone(
    String categoryId,
    String zoneId,
  ) async {
    await printerService.setCategoryZoneMapping(categoryId, zoneId);
  }

  /* asignar varias categorias a una zona de forma masiva */
  Future<void> bulkAssignCategoriesToZone({
    required List<String> categoryIds,
    required String zoneId,
  }) async {
    if (zoneId == kCajaZoneId) {
      await printerService.bulkSetCategoryZoneMapping(categoryIds, kCajaZoneId);
    } else {
      await printerService.bulkSetCategoryZoneMapping(categoryIds, zoneId);
    }
    selectedCategoryIds.clear();
  }

  /* categorias que NO tienen mapeo local (categoria -> zona). */
  List<String> unassignedCategoryIds() {
    return categories
        .map((c) => c.id)
        .where((id) => id != null && !categoryZoneMappings.containsKey(id))
        .cast<String>()
        .toList();
  }

  /* asignar TODAS las categorias sin zona a la zona indicada. */
  Future<int> assignAllUnassignedToZone(String zoneId) async {
    final List<String> ids = unassignedCategoryIds();
    if (ids.isEmpty) return 0;
    await printerService.bulkSetCategoryZoneMapping(ids, zoneId);
    return ids.length;
  }

  void toggleCategorySelection(String categoryId) {
    if (selectedCategoryIds.contains(categoryId)) {
      selectedCategoryIds.remove(categoryId);
    } else {
      selectedCategoryIds.add(categoryId);
    }
  }

  void clearSelection() {
    selectedCategoryIds.clear();
  }
}
