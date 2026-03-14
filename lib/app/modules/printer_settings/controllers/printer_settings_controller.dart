import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:blue_thermal_printer/blue_thermal_printer.dart';
import 'package:restic_movil/app/data/services/printer_service.dart';
import 'package:restic_movil/core/utils/animations/loading_charging.dart';
import 'package:restic_movil/core/utils/modals/modal_info.dart';
import 'package:restic_movil/core/utils/snackbars/error_snackbar.dart';
import 'package:restic_movil/core/utils/snackbars/info_snackbar.dart';

class PrinterSettingsController extends GetxController {
  final PrinterService printerService = Get.find<PrinterService>();

  // State
  RxBool get isConnected => printerService.isConnected;
  RxBool get isBluetoothOn => printerService.isBluetoothOn;
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
          Get.dialog(
            ModalInfo(
              title: 'Éxito',
              message: 'Conectado a ${device.name}',
              icon: Icons.check_circle_outline,
              iconColor: Colors.green,
            ),
          );
        } else {
          Get.showSnackbar(
            ErrorSnackbar('No se pudo conectar a ${device.name}'),
          );
        }
      },
      loadingWidget: const LoadingCharging(),
    );
  }

  /* desconectar la impresora actual */
  Future<void> disconnect() async {
    Get.showOverlay(
      asyncFunction: () async {
        await printerService.disconnect();
        Get.showSnackbar(
          const InfoSnackbar('Impresora desconectada correctamente'),
        );
      },
      loadingWidget: const LoadingCharging(),
    );
  }
}
