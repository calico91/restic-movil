import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:restic_movil/app/data/models/printer_zone_model.dart';
import 'package:restic_movil/app/modules/printer_settings/controllers/printer_settings_controller.dart';
import 'package:restic_movil/core/utils/helpers/error_handler.dart';
import 'package:restic_movil/core/utils/printers/category_printer_resolver.dart';
import 'package:restic_movil/core/utils/snackbars/info_snackbar.dart';

/// Muestra un dialog para asignar TODAS las categorias sin zona a una
/// zona destino elegida en un dropdown.
Future<void> showAssignAllUnassignedDialog(
  List<PrinterZoneModel> allZones,
) async {
  final PrinterSettingsController controller =
      Get.find<PrinterSettingsController>();
  final int pending = controller.unassignedCategoryIds().length;
  if (pending == 0) return;

  String? selectedZoneId;
  await Get.dialog<bool>(
    AlertDialog(
      title: const Text('Asignar todas las no asignadas'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Text(
              'Hay $pending categoria(s) sin zona asignada. Elige la zona '
              'a la que se enviaran todas:',
              style: const TextStyle(fontSize: 13),
            ),
          ),
          StatefulBuilder(
            builder: (ctx, setSt) {
              return DropdownButtonFormField<String>(
                initialValue: selectedZoneId,
                isExpanded: true,
                decoration: const InputDecoration(
                  labelText: 'Zona destino',
                  border: OutlineInputBorder(),
                  isDense: true,
                ),
                items: allZones
                    .map(
                      (z) => DropdownMenuItem<String>(
                        value: z.id ?? kCajaZoneId,
                        child: Text(
                          z.isCaja
                              ? 'Caja (impresora principal)'
                              : (z.name ?? 'Zona'),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    )
                    .toList(),
                onChanged: (v) => setSt(() => selectedZoneId = v),
              );
            },
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Get.back(result: false),
          child: const Text('Cancelar'),
        ),
        ElevatedButton(
          onPressed: () async {
            if (selectedZoneId == null) {
              ErrorHandler.showErrorDialog('Selecciona una zona');
              return;
            }
            final int count = await controller.assignAllUnassignedToZone(
              selectedZoneId!,
            );
            Get.back(result: true);
            Get.showSnackbar(
              InfoSnackbar('Asignadas $count categoria(s)'),
            );
          },
          child: const Text('Asignar'),
        ),
      ],
    ),
  );
}
