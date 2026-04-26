import 'dart:ui';
import 'package:blue_thermal_printer/blue_thermal_printer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:restic_movil/app/data/services/printer_service.dart';
import 'package:restic_movil/app/modules/printer_settings/controllers/printer_settings_controller.dart';

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
