import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:blue_thermal_printer/blue_thermal_printer.dart';
import 'package:restic_movil/app/data/models/category_model.dart';
import 'package:restic_movil/app/data/models/network_printer_model.dart';
import 'package:restic_movil/app/data/models/printer_zone_model.dart';
import 'package:restic_movil/app/data/repositories/categories_repository.dart';
import 'package:restic_movil/app/data/repositories/printer_zone_repository.dart';
import 'package:restic_movil/app/data/services/printer_service.dart';
import 'package:restic_movil/core/utils/animations/loading_charging.dart';
import 'package:restic_movil/core/utils/enums/printer_connection_type.dart';
import 'package:restic_movil/core/utils/modals/modal_info.dart';
import 'package:restic_movil/core/utils/helpers/error_handler.dart';
import 'package:restic_movil/core/utils/modals/modal_error.dart';
import 'package:restic_movil/core/utils/validators/ip_validator.dart';
import 'package:restic_movil/core/utils/snackbars/info_snackbar.dart';

class PrinterSettingsController extends GetxController {
  final PrinterService printerService = Get.find<PrinterService>();
  final CategoriesRepository _categoriesRepository = Get.find<CategoriesRepository>();
  final PrinterZoneRepository _printerZoneRepository = Get.find<PrinterZoneRepository>();

  RxBool get isConnected => printerService.isConnected;
  RxBool get isBluetoothOn => printerService.isBluetoothOn;
  RxList<BluetoothDevice> get devices => printerService.devices;
  Rx<BluetoothDevice?> get selectedDevice => printerService.selectedDevice;

  Rx<NetworkPrinterModel?> get networkConfig => printerService.networkConfig;
  RxBool get isNetworkConnected => printerService.isNetworkConnected;
  Rx<PrinterConnectionType> get connectionType => printerService.connectionType;

  final TextEditingController ipController = TextEditingController();
  final TextEditingController portController =
      TextEditingController(text: '9100');

  final RxString selectedPrinterSize = '58mm'.obs;

  final RxList<CategoryModel> categories = <CategoryModel>[].obs;
  final RxBool isLoadingCategories = false.obs;

  RxList<PrinterZoneModel> get zones => printerService.zones;

  final RxSet<String> selectedCategoryIds = <String>{}.obs;

  @override
  void onInit() {
    super.onInit();
    scanDevices();
    _loadPrinterSize();
    _populateNetworkFields();
    _loadCategories();
    _loadZones();
  }

  @override
  void onClose() {
    ipController.dispose();
    portController.dispose();
    super.onClose();
  }

  Future<void> _loadPrinterSize() async {
    selectedPrinterSize.value = printerService.printerSize.value;
  }

  void _populateNetworkFields() {
    final config = printerService.networkConfig.value;
    if (config != null) {
      ipController.text = config.ip;
      portController.text = config.port.toString();
    }
  }

  Future<void> setPrinterSize(String size) async {
    await printerService.setPrinterSize(size);
    selectedPrinterSize.value = size;
  }

  Future<void> scanDevices() async {
    await printerService.getDevices();
  }

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

  Future<void> _loadCategories() async {
    isLoadingCategories.value = true;
    try {
      final List<CategoryModel> result =
          await _categoriesRepository.getCategories();
      categories.assignAll(result);
    } catch (e) {
      ErrorHandler.showErrorDialog('Error al cargar categorías');
    } finally {
      isLoadingCategories.value = false;
    }
  }

  Future<void> _loadZones() async {
    await printerService.loadZonesFromBackend();
  }

  PrinterZoneModel? get cajaZone => printerService.cajaZone;

  List<PrinterZoneModel> get allZones => printerService.allZones;

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

    try {
      final zone = await _printerZoneRepository.create(
        name: trimmedName,
        ip: trimmedIp,
        port: port,
      );
      zones.add(zone);
      return true;
    } catch (e) {
      ErrorHandler.showErrorDialog('Error al crear zona: $e');
      return false;
    }
  }

  Future<bool> updateZone({
    required String zoneId,
    required String name,
    required String ip,
    required int port,
  }) async {
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

    try {
      final updated = await _printerZoneRepository.update(
        id: zoneId,
        name: trimmedName,
        ip: trimmedIp,
        port: port,
      );
      final idx = zones.indexWhere((z) => z.id == zoneId);
      if (idx != -1) {
        zones[idx] = updated;
      }
      return true;
    } catch (e) {
      ErrorHandler.showErrorDialog('Error al actualizar zona: $e');
      return false;
    }
  }

  Future<bool> deleteZone(String zoneId) async {
    try {
      await _printerZoneRepository.delete(zoneId);
      zones.removeWhere((z) => z.id == zoneId);
      final affected = categories
          .where((c) => c.printerZone?.id == zoneId)
          .map((c) => c.id)
          .where((id) => id != null)
          .cast<String>()
          .toList();
      for (final catId in affected) {
        await assignCategoryToZone(catId, null);
      }
      return true;
    } catch (e) {
      ErrorHandler.showErrorDialog('Error al eliminar zona: $e');
      return false;
    }
  }

  String zoneNameForCategory(String categoryId) {
    final cat = categories.firstWhereOrNull((c) => c.id == categoryId);
    if (cat == null) return 'Sin asignar';
    if (cat.printerZone == null) {
      return printerService.cajaZone != null ? 'Caja' : 'Sin asignar';
    }
    return cat.printerZone!.name ?? 'Sin asignar';
  }

  Future<void> assignCategoryToZone(
    String categoryId,
    String? zoneId,
  ) async {
    try {
      final updated = await _categoriesRepository.updateCategoryPrinter(
        categoryId,
        printerZoneId: zoneId,
      );
      final idx = categories.indexWhere((c) => c.id == categoryId);
      if (idx != -1) {
        categories[idx] = updated;
      }
    } catch (e) {
      ErrorHandler.showErrorDialog('Error al asignar zona: $e');
    }
  }

  Future<void> bulkAssignCategoriesToZone({
    required List<String> categoryIds,
    required String? zoneId,
  }) async {
    try {
      for (final catId in categoryIds) {
        await _categoriesRepository.updateCategoryPrinter(
          catId,
          printerZoneId: zoneId,
        );
      }
      await _loadCategories();
      selectedCategoryIds.clear();
    } catch (e) {
      ErrorHandler.showErrorDialog('Error en asignación masiva: $e');
    }
  }

  List<String> unassignedCategoryIds() {
    return categories
        .map((c) => c.id)
        .where((id) => id != null && categories
            .firstWhereOrNull((cat) => cat.id == id)
            ?.printerZone ==
            null)
        .cast<String>()
        .toList();
  }

  Future<int> assignAllUnassignedToZone(String? zoneId) async {
    final List<String> ids = unassignedCategoryIds();
    if (ids.isEmpty) return 0;
    await bulkAssignCategoriesToZone(categoryIds: ids, zoneId: zoneId);
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
