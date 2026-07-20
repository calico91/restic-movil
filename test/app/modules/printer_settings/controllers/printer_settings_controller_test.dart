import 'dart:ui';
import 'package:blue_thermal_printer/blue_thermal_printer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:restic_movil/app/data/models/category_model.dart';
import 'package:restic_movil/app/data/models/network_printer_model.dart';
import 'package:restic_movil/app/data/models/order_detail_model.dart';
import 'package:restic_movil/app/data/models/order_item_model.dart';
import 'package:restic_movil/app/data/models/order_model.dart';
import 'package:restic_movil/app/data/models/printer_zone_model.dart';
import 'package:restic_movil/app/data/repositories/categories_repository.dart';
import 'package:restic_movil/app/data/services/printer_service.dart';
import 'package:restic_movil/app/modules/printer_settings/controllers/printer_settings_controller.dart';
import 'package:restic_movil/core/utils/enums/printer_connection_type.dart';
import 'package:restic_movil/core/utils/printers/printable_ticket.dart';

class MockCategoriesRepository implements CategoriesRepository {
  @override
  Future<List<CategoryModel>> getCategories() async => <CategoryModel>[];

  @override
  Future<void> createCategory(Map<String, dynamic> data) async {}

  @override
  Future<void> updateCategory(String id, Map<String, dynamic> data) async {}

  @override
  Future<void> createSubcategory(Map<String, dynamic> data) async {}

  @override
  Future<void> updateSubcategory(String id, Map<String, dynamic> data) async {}

  @override
  Future<void> createProduct(Map<String, dynamic> data) async {}

  @override
  Future<void> updateProduct(String id, Map<String, dynamic> data) async {}

  @override
  Future<CategoryModel> updateCategoryPrinter(
    String id, {
    required String? printerIp,
    required int? printerPort,
  }) async {
    return CategoryModel(id: id);
  }
}

class MockPrinterService extends GetxService implements PrinterService {
  @override
  RxBool isConnected = false.obs;

  @override
  RxBool isBluetoothOn = true.obs;

  @override
  RxList<BluetoothDevice> devices = <BluetoothDevice>[].obs;

  @override
  Rx<BluetoothDevice?> selectedDevice = Rx<BluetoothDevice?>(null);

  @override
  RxString printerSize = '58mm'.obs;

  @override
  Rx<NetworkPrinterModel?> networkConfig = Rx<NetworkPrinterModel?>(null);

  @override
  RxBool isNetworkConnected = false.obs;

  @override
  Rx<PrinterConnectionType> connectionType = PrinterConnectionType.bluetooth.obs;

  @override
  RxList<PrinterZoneModel> zones = <PrinterZoneModel>[].obs;

  @override
  RxMap<String, String> categoryZoneMappings = <String, String>{}.obs;

  @override
  Future<void> persistZones() async {}

  @override
  Future<void> setCategoryZoneMapping(String categoryId, String? zoneId) async {
    if (zoneId == null) {
      categoryZoneMappings.remove(categoryId);
    } else {
      categoryZoneMappings[categoryId] = zoneId;
    }
  }

  @override
  Future<void> bulkSetCategoryZoneMapping(
    List<String> categoryIds,
    String zoneId,
  ) async {
    for (final String id in categoryIds) {
      categoryZoneMappings[id] = zoneId;
    }
  }

  @override
  PrinterZoneModel? get cajaZone => networkConfig.value == null
      ? null
      : PrinterZoneModel(
          id: '__caja__',
          name: 'Caja',
          ip: networkConfig.value!.ip,
          port: networkConfig.value!.port,
          isCaja: true,
        );

  @override
  List<PrinterZoneModel> get allZones {
    final List<PrinterZoneModel> list = <PrinterZoneModel>[];
    final PrinterZoneModel? caja = cajaZone;
    if (caja != null) list.add(caja);
    list.addAll(zones);
    return list;
  }

  @override
  Future<void> setPrinterSize(String size) async {
    printerSize.value = size;
  }

  @override
  Future<void> getDevices() async {
     devices.assignAll([
       BluetoothDevice("Impresora Termica", "00:11:22:33:44"),
     ]);
  }

  @override
  Future<bool> connect(BluetoothDevice device) async {
    isConnected.value = true;
    selectedDevice.value = device;
    return true;
  }

  @override
  Future<void> disconnect() async {
    isConnected.value = false;
    selectedDevice.value = null;
  }
  
  @override
  Future<void> autoConnect() async {}

  @override
  Future<void> printTicket(dynamic data) async {}

  @override
  Future<bool> connectNetwork(NetworkPrinterModel config) async {
    networkConfig.value = config;
    isNetworkConnected.value = true;
    connectionType.value = PrinterConnectionType.network;
    return true;
  }

  @override
  Future<void> disconnectNetwork() async {
    isNetworkConnected.value = false;
    networkConfig.value = null;
    connectionType.value = PrinterConnectionType.bluetooth;
  }

  @override
  Future<void> printTestPage() async {}

  @override
  Future<void> printTicketToSpecificNetwork(
    PrintableTicket ticket,
    String ip,
    int port, {
    String? displayName,
  }) async {}

  @override
  Future<void> printComandaMultiPrinter({
    required OrderModel order,
    required List<OrderItemModel> sourceItems,
    required List<CategoryModel> categories,
    required PrintableTicket Function(OrderModel, List<OrderItemModel>) ticketBuilder,
  }) async {}

  @override
  Future<void> printComandaMultiPrinterFromDetails({
    required OrderModel order,
    required List<OrderDetailModel> details,
    required List<CategoryModel> categories,
    required PrintableTicket Function(OrderModel, List<OrderDetailModel>) ticketBuilder,
  }) async {}

  // Dummy Methods
  @override
  get bluetooth => throw UnimplementedError();
  @override Future<void> initBluetooth() async {}
  void initPrinter() {}
  Future<void> printBill(Map<String, dynamic> data, {bool openCashDrawer = false}) async {}
  Future<void> printExpense(Map<String, dynamic> data) async {}
  Future<void> printZReport(Map<String, dynamic> reportData) async {}
  @override void didChangeAppLifecycleState(dynamic state) {}
  @override void didChangeAccessibilityFeatures() {}
  @override void didChangeLocales(dynamic locales) {}
  @override void didChangeMetrics() {}
  @override void didChangePlatformBrightness() {}
  @override void didChangeTextScaleFactor() {}
  @override void didChangeViewFocus(dynamic event) {}
  @override void didHaveMemoryPressure() {}
  @override Future<bool> didPopRoute() async => true;
  @override Future<bool> didPushRoute(String route) async => true;
  @override Future<bool> didPushRouteInformation(dynamic routeInformation) async => true;
  @override Future<AppExitResponse> didRequestAppExit() async => AppExitResponse.exit;
  @override void handleCancelBackGesture() {}
  @override void handleCommitBackGesture() {}
  @override bool handleStartBackGesture(dynamic details) => false;
  @override void handleUpdateBackGestureProgress(dynamic details) {}
}

class TestPrinterSettingsController extends PrinterSettingsController {
// Override onInit scan Devices
}

void main() {
  group('Pruebas de Controller - PrinterSettings', () {
    late TestPrinterSettingsController controller;
    late MockPrinterService mockPrinterService;

    setUp(() {
      Get.reset();
      Get.testMode = true;
      mockPrinterService = MockPrinterService();
      Get.put<PrinterService>(mockPrinterService);
      Get.put<CategoriesRepository>(MockCategoriesRepository());
      controller = Get.put(TestPrinterSettingsController());
    });

    testWidgets('Debe cargar lista de dispositivos desde el servicio', (tester) async {
      await tester.pumpWidget(const GetMaterialApp(home: Scaffold(body: SizedBox())));
      await controller.scanDevices();
      
      expect(controller.devices.length, 1);
      expect(controller.devices.first.name, "Impresora Termica");
    });
    
    testWidgets('Debe reflejar estado de conexion correctamente al servicio subyacente', (tester) async {
      await tester.pumpWidget(const GetMaterialApp(home: Scaffold(body: SizedBox())));
      await controller.scanDevices();

      expect(controller.isConnected.value, false);

      await tester.runAsync(() async {
        await controller.connect(controller.devices.first);
      });
      await tester.pumpAndSettle();
      
      expect(controller.isConnected.value, true);
    });
  });
}
