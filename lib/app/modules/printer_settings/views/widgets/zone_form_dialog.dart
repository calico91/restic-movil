import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:restic_movil/app/data/models/printer_zone_model.dart';
import 'package:restic_movil/app/modules/printer_settings/controllers/printer_settings_controller.dart';
import 'package:restic_movil/core/utils/snackbars/info_snackbar.dart';
import 'package:restic_movil/core/utils/validators/ip_validator.dart';

/// Abre un dialog con formulario para crear o editar una zona.
/// Retorna `true` si se guardo, `false` o `null` si se cancelo.
Future<bool?> showZoneFormDialog({PrinterZoneModel? zone}) {
  return Get.dialog<bool>(
    ZoneFormDialog(zone: zone),
  );
}

class ZoneFormDialog extends StatelessWidget {
  final PrinterZoneModel? zone;

  const ZoneFormDialog({super.key, this.zone});

  @override
  Widget build(BuildContext context) {
    final TextEditingController nameCtrl =
        TextEditingController(text: zone?.name ?? '');
    final TextEditingController ipCtrl =
        TextEditingController(text: zone?.ip ?? '');
    final TextEditingController portCtrl = TextEditingController(
      text: (zone?.port ?? 9100).toString(),
    );
    final GlobalKey<FormState> formKey = GlobalKey<FormState>();

    final bool isNew = zone == null;

    return AlertDialog(
      title: Text(isNew ? 'Nueva Zona' : 'Editar Zona'),
      content: Form(
        key: formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: nameCtrl,
              decoration: const InputDecoration(
                labelText: 'Nombre',
                hintText: 'Ej. Jugos, Caliente, Barra',
              ),
              validator: (v) =>
                  (v ?? '').trim().isEmpty ? 'Ingresa un nombre' : null,
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: ipCtrl,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'IP',
                hintText: '192.168.1.101',
              ),
              validator: (v) => IpValidator.validate(v),
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: portCtrl,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Puerto'),
              validator: (v) {
                final int? p = int.tryParse((v ?? '').trim());
                if (p == null || p < 1 || p > 65535) {
                  return 'Puerto invalido';
                }
                return null;
              },
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Get.back(result: false),
          child: const Text('Cancelar'),
        ),
        ElevatedButton(
          onPressed: () async {
            if (!(formKey.currentState?.validate() ?? false)) return;
            final int port = int.parse(portCtrl.text.trim());
            final PrinterSettingsController controller =
                Get.find<PrinterSettingsController>();
            if (isNew) {
              await controller.addZone(
                name: nameCtrl.text,
                ip: ipCtrl.text,
                port: port,
              );
            } else {
              await controller.updateZone(
                zoneId: zone!.id!,
                name: nameCtrl.text,
                ip: ipCtrl.text,
                port: port,
              );
            }
            Get.back(result: true);
            Get.showSnackbar(
              InfoSnackbar(isNew ? 'Zona agregada' : 'Zona actualizada'),
            );
          },
          child: const Text('Guardar'),
        ),
      ],
    );
  }
}
