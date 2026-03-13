import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:blue_thermal_printer/blue_thermal_printer.dart';
import 'package:restic_movil/app/data/services/printer_service.dart';

class PrinterSettingsController extends GetxController {
  final PrinterService printerService = Get.find<PrinterService>();

  // State
  RxBool get isConnected => printerService.isConnected;
  RxList<BluetoothDevice> get devices => printerService.devices;
  Rx<BluetoothDevice?> get selectedDevice => printerService.selectedDevice;

  @override
  void onInit() {
    super.onInit();
    scanDevices();
  }

  /* escanear dispositivos bluetooth vinculados */
  Future<void> scanDevices() async {
    await printerService.getDevices();
  }

  /* conectar a la impresora seleccionada */
  Future<void> connect(BluetoothDevice device) async {
    Get.showOverlay(
      asyncFunction: () async {
        final success = await printerService.connect(device);
        if (success) {
          Get.snackbar(
            'Éxito',
            'Conectado a ${device.name}',
            snackPosition: SnackPosition.BOTTOM,
          );
        } else {
          Get.snackbar(
            'Error',
            'No se pudo conectar a ${device.name}',
            snackPosition: SnackPosition.BOTTOM,
          );
        }
      },
      loadingWidget: const Center(child: CircularProgressIndicator()),
    );
  }

  /* desconectar la impresora actual */
  Future<void> disconnect() async {
    Get.showOverlay(
      asyncFunction: () async {
        await printerService.disconnect();
        Get.snackbar(
          'Desconectado',
          'Impresora desconectada correctamente',
          snackPosition: SnackPosition.BOTTOM,
        );
      },
      loadingWidget: const Center(child: CircularProgressIndicator()),
    );
  }
}
