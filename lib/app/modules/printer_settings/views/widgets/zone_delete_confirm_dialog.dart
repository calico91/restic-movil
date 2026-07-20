import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:restic_movil/app/data/models/printer_zone_model.dart';
import 'package:restic_movil/app/modules/printer_settings/controllers/printer_settings_controller.dart';
import 'package:restic_movil/core/utils/snackbars/info_snackbar.dart';

/// Muestra un dialog de confirmacion para eliminar una zona. Si el usuario
/// confirma, llama a [PrinterSettingsController.deleteZone] y muestra un
/// snackbar de exito.
Future<void> confirmZoneDelete(PrinterZoneModel zone) async {
  final PrinterSettingsController controller =
      Get.find<PrinterSettingsController>();

  final bool? ok = await Get.dialog<bool>(
    AlertDialog(
      title: const Text('Eliminar zona'),
      content: Text(
        '¿Eliminar la zona "${zone.name}"? Las categorias que la usaban '
        'volveran a "Caja".',
      ),
      actions: [
        TextButton(
          onPressed: () => Get.back(result: false),
          child: const Text('Cancelar'),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
          onPressed: () => Get.back(result: true),
          child: const Text('Eliminar'),
        ),
      ],
    ),
  );

  if (ok == true) {
    await controller.deleteZone(zone.id!);
    Get.showSnackbar(const InfoSnackbar('Zona eliminada'));
  }
}
