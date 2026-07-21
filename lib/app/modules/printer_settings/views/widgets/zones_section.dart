import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:restic_movil/app/data/models/printer_zone_model.dart';
import 'package:restic_movil/app/modules/printer_settings/controllers/printer_settings_controller.dart';
import 'zone_form_dialog.dart';
import 'zone_delete_confirm_dialog.dart';

/// Seccion "Zonas de Impresion": tarjeta informativa de Caja, lista de
/// zonas custom con acciones editar/eliminar, y boton para agregar.
class ZonesSection extends StatelessWidget {
  const ZonesSection({super.key});

  @override
  Widget build(BuildContext context) {
    final PrinterSettingsController controller =
        Get.find<PrinterSettingsController>();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Padding(
          padding: EdgeInsets.only(bottom: 8),
          child: Text(
            'Crea zonas (p. ej. "Jugos", "Caliente") con su IP y puerto. '
            'Luego asigna categorias a cada zona con un toque. '
            'La zona "Caja" siempre equivale a la impresora de red principal.',
            style: TextStyle(fontSize: 12, color: Colors.black54),
          ),
        ),
        const CajaZoneCard(),
        const SizedBox(height: 8),
        Obx(() {
          if (controller.zones.isEmpty) {
            return const Padding(
              padding: EdgeInsets.symmetric(vertical: 8),
              child: Text(
                'No hay zonas adicionales configuradas.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey, fontSize: 12),
              ),
            );
          }
          return Column(
            children:
                controller.zones.map((z) => ZoneCard(zone: z)).toList(),
          );
        }),
        const SizedBox(height: 8),
        ElevatedButton.icon(
          onPressed: () => showZoneFormDialog(),
          icon: const Icon(Icons.add, size: 20),
          label: const Text('Agregar Zona'),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF0D47A1),
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 12),
          ),
        ),
      ],
    );
  }
}

/// Tarjeta que muestra la zona "Caja" (derivada de la impresora de red
/// principal). No se puede editar ni eliminar desde aca.
class CajaZoneCard extends StatelessWidget {
  const CajaZoneCard({super.key});

  @override
  Widget build(BuildContext context) {
    final PrinterSettingsController controller =
        Get.find<PrinterSettingsController>();

    return Obx(() {
      final PrinterZoneModel? caja = controller.cajaZone;
      return Card(
        margin: const EdgeInsets.only(bottom: 8),
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(
            color: Colors.green.withValues(alpha: 0.5),
            width: 1.5,
          ),
        ),
        child: ListTile(
          leading: const Icon(Icons.point_of_sale, color: Colors.green),
          title: const Text(
            'Caja (impresora principal)',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
          ),
          subtitle: Text(
            caja != null
                ? '${caja.ip}:${caja.port}'
                : 'Configura la impresora de red arriba para activarla',
            style: const TextStyle(fontSize: 12),
          ),
          trailing: const Chip(
            label: Text('Automatica'),
            backgroundColor: Color(0x3300C853),
            labelStyle: TextStyle(fontSize: 10, color: Colors.green),
            padding: EdgeInsets.zero,
            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
        ),
      );
    });
  }
}

/// Tarjeta de una zona custom con acciones Editar / Eliminar.
class ZoneCard extends StatelessWidget {
  final PrinterZoneModel zone;

  const ZoneCard({super.key, required this.zone});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: const Color(0xFF0D47A1).withValues(alpha: 0.5),
          width: 1.5,
        ),
      ),
      child: ListTile(
        leading: const Icon(Icons.workspaces, color: Color(0xFF0D47A1)),
        title: Text(
          zone.name ?? 'Zona',
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
        ),
        subtitle: Text(
          '${zone.ip}:${zone.port ?? 9100}',
          style: const TextStyle(fontSize: 12),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              tooltip: 'Editar',
              onPressed: () => showZoneFormDialog(zone: zone),
              icon: const Icon(Icons.edit, color: Color(0xFF0D47A1), size: 20),
            ),
            IconButton(
              tooltip: 'Eliminar',
              onPressed: () => confirmZoneDelete(zone),
              icon:
                  const Icon(Icons.delete_outline, color: Colors.red, size: 20),
            ),
          ],
        ),
      ),
    );
  }
}
