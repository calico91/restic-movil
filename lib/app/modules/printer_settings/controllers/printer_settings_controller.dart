import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:blue_thermal_printer/blue_thermal_printer.dart';
import 'package:restic_movil/app/data/models/category_model.dart';
import 'package:restic_movil/app/data/models/network_printer_model.dart';
import 'package:restic_movil/app/data/repositories/categories_repository.dart';
import 'package:restic_movil/app/data/services/printer_service.dart';
import 'package:restic_movil/core/utils/animations/loading_charging.dart';
import 'package:restic_movil/core/utils/enums/printer_connection_type.dart';
import 'package:restic_movil/core/utils/helpers/exception_handler.dart';
import 'package:restic_movil/core/utils/modals/modal_info.dart';
import 'package:restic_movil/core/utils/modals/modal_error.dart';
import 'package:restic_movil/core/utils/snackbars/info_snackbar.dart';

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

  // Categorias con configuracion de impresora
  final RxList<CategoryModel> categories = <CategoryModel>[].obs;
  final RxBool isLoadingCategories = false.obs;
  // Mapa de controladores de texto por categoria: categoryId -> [ipController, portController]
  final Map<String, List<TextEditingController>> categoryControllers = {};

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
    // Liberar controladores de categorias
    for (final controllers in categoryControllers.values) {
      for (final c in controllers) {
        c.dispose();
      }
    }
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
          Get.dialog(ModalError(message: 'No se pudo conectar a ${device.name}'),
          );
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

    if (ip.isEmpty || port == null) {
      Get.dialog(const ModalError(message: 'Ingresa una IP y un puerto válidos'),
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
          Get.dialog(ModalError(message: 'No se pudo conectar a $ip:$port'),
          );
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
          final String errorMessage = ExceptionHandler.extractMessage(e);
          Get.dialog(ModalError(message: errorMessage));
        }
      },
      loadingWidget: const LoadingCharging(),
    );
  }

  /* cargar todas las categorias de la sucursal con su configuracion de impresora */
  Future<void> _loadCategories() async {
    isLoadingCategories.value = true;
    try {
      final List<CategoryModel> result = await _categoriesRepository.getCategories();
      categories.assignAll(result);
      _initCategoryControllers(result);
    } catch (e) {
      Get.dialog(const ModalError(message: 'Error al cargar categorías'));
    } finally {
      isLoadingCategories.value = false;
    }
  }

  /* inicializar controladores de texto por categoria con valores guardados */
  void _initCategoryControllers(List<CategoryModel> cats) {
    for (final CategoryModel cat in cats) {
      if (cat.id == null) continue;
      categoryControllers[cat.id!] = [
        TextEditingController(text: cat.printerIp ?? ''),
        TextEditingController(text: cat.printerPort?.toString() ?? '9100'),
      ];
    }
  }

  /* guardar la impresora asignada a una categoria */
  Future<void> saveCategoryPrinter(String categoryId) async {
    final List<TextEditingController>? controllers = categoryControllers[categoryId];
    if (controllers == null) return;

    final String ip = controllers[0].text.trim();
    final String portText = controllers[1].text.trim();
    final int? port = int.tryParse(portText);

    if (ip.isEmpty) {
      Get.dialog(const ModalError(message: 'Ingresa una IP válida'));
      return;
    }
    if (port == null || port < 1 || port > 65535) {
      Get.dialog(const ModalError(message: 'Ingresa un puerto válido (1-65535)'));
      return;
    }

    Get.showOverlay(
      asyncFunction: () async {
        try {
          final CategoryModel updated = await _categoriesRepository.updateCategoryPrinter(
            categoryId,
            printerIp: ip,
            printerPort: port,
          );
          // Actualizar en la lista reactiva
          final int idx = categories.indexWhere((c) => c.id == categoryId);
          if (idx != -1) categories[idx] = updated;
          Get.showSnackbar(const InfoSnackbar('Impresora asignada correctamente'));
        } catch (e) {
          final String errorMessage = ExceptionHandler.extractMessage(e);
          Get.dialog(ModalError(message: errorMessage));
        }
      },
      loadingWidget: const LoadingCharging(),
    );
  }

  /* eliminar la impresora asignada a una categoria */
  Future<void> removeCategoryPrinter(String categoryId) async {
    Get.showOverlay(
      asyncFunction: () async {
        try {
          final CategoryModel updated = await _categoriesRepository.updateCategoryPrinter(
            categoryId,
            printerIp: null,
            printerPort: null,
          );
          final int idx = categories.indexWhere((c) => c.id == categoryId);
          if (idx != -1) categories[idx] = updated;
          // Limpiar campos de texto
          categoryControllers[categoryId]?[0].text = '';
          categoryControllers[categoryId]?[1].text = '9100';
          Get.showSnackbar(const InfoSnackbar('Impresora de categoría eliminada'));
        } catch (e) {
          final String errorMessage = ExceptionHandler.extractMessage(e);
          Get.dialog(ModalError(message: errorMessage));
        }
      },
      loadingWidget: const LoadingCharging(),
    );
  }
}
