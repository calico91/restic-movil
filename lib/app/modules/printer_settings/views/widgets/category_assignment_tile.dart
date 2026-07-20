import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:restic_movil/app/modules/printer_settings/controllers/printer_settings_controller.dart';
import 'package:restic_movil/core/utils/printers/category_printer_resolver.dart';

/// Tile que muestra una categoria con su zona asignada y un checkbox
/// para seleccionarla y luego aplicar una operacion bulk.
class CategoryAssignmentTile extends StatelessWidget {
  final dynamic category;

  const CategoryAssignmentTile({super.key, required this.category});

  @override
  Widget build(BuildContext context) {
    final String? catId = category.id;
    if (catId == null) return const SizedBox.shrink();

    final PrinterSettingsController controller =
        Get.find<PrinterSettingsController>();

    return Obx(() {
      final bool selected = controller.selectedCategoryIds.contains(catId);
      final String zoneName = controller.zoneNameForCategory(catId);
      final bool isCaja =
          controller.zoneIdForCategory(catId) == kCajaZoneId;

      return Card(
        margin: const EdgeInsets.only(bottom: 6),
        elevation: selected ? 3 : 1,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
          side: BorderSide(
            color:
                selected ? const Color(0xFF0D47A1) : Colors.transparent,
            width: selected ? 2 : 0,
          ),
        ),
        child: CheckboxListTile(
          value: selected,
          onChanged: (_) => controller.toggleCategorySelection(catId),
          controlAffinity: ListTileControlAffinity.leading,
          dense: true,
          title: Text(
            category.name ?? 'Categoria',
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
          ),
          subtitle: Padding(
            padding: const EdgeInsets.only(top: 2),
            child: Row(
              children: [
                Icon(
                  isCaja ? Icons.point_of_sale : Icons.workspaces_outlined,
                  size: 14,
                  color: isCaja ? Colors.green : const Color(0xFF0D47A1),
                ),
                const SizedBox(width: 4),
                Text(
                  'Zona: $zoneName',
                  style: TextStyle(
                    fontSize: 12,
                    color: isCaja
                        ? Colors.green.shade700
                        : const Color(0xFF0D47A1),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    });
  }
}
