import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:restic_movil/app/data/models/printer_zone_model.dart';
import 'package:restic_movil/app/modules/printer_settings/controllers/printer_settings_controller.dart';
import 'bulk_assignment_bar.dart';
import 'category_assignment_tile.dart';

/// Seccion completa de "Asignar Categorias a Zonas": texto de ayuda,
/// barra de asignacion bulk y lista de tiles por categoria.
class CategoryAssignmentSection extends StatelessWidget {
  const CategoryAssignmentSection({super.key});

  @override
  Widget build(BuildContext context) {
    final PrinterSettingsController controller =
        Get.find<PrinterSettingsController>();

    return Obx(() {
      if (controller.isLoadingCategories.value) {
        return const Padding(
          padding: EdgeInsets.symmetric(vertical: 16),
          child: Center(child: CircularProgressIndicator()),
        );
      }
      if (controller.categories.isEmpty) {
        return const Padding(
          padding: EdgeInsets.symmetric(vertical: 12),
          child: Text(
            'No hay categorias disponibles.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey, fontSize: 13),
          ),
        );
      }

      final List<PrinterZoneModel> allZones = controller.allZones;
      if (allZones.isEmpty) {
        return const Padding(
          padding: EdgeInsets.symmetric(vertical: 8),
          child: Text(
            'Configura la impresora de red en la seccion "Conexion por Red" '
            'para activar la zona Caja.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey, fontSize: 12),
          ),
        );
      }

      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Padding(
            padding: EdgeInsets.only(bottom: 8),
            child: Text(
              'Selecciona varias categorias y envialas a una zona con un solo '
              'toque. Las categorias sin asignar imprimiran sus comandas en la '
              'impresora principal (Caja o Bluetooth activo).',
              style: TextStyle(fontSize: 12, color: Colors.black54),
            ),
          ),
          const SizedBox(height: 8),
          BulkAssignmentBar(allZones: allZones),
          const SizedBox(height: 8),
          ...controller.categories
              .map((c) => CategoryAssignmentTile(category: c)),
        ],
      );
    });
  }
}
