import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:restic_movil/app/data/models/printer_zone_model.dart';
import 'package:restic_movil/app/modules/printer_settings/controllers/printer_settings_controller.dart';
import 'package:restic_movil/core/utils/helpers/error_handler.dart';
import 'package:restic_movil/core/utils/printers/category_printer_resolver.dart';
import 'package:restic_movil/core/utils/snackbars/info_snackbar.dart';
import 'assign_all_unassigned_dialog.dart';

/// ID privado reservado para la opcion "Sin asignar" en el dropdown bulk.
/// No es una zona real: indica que se debe limpiar la asignacion de las
/// categorias seleccionadas (vuelven a la impresora por defecto).
const String _kUnassignedZoneId = '__unassigned__';

/// Barra de asignacion bulk: contador de seleccion, dropdown con zonas
/// (incluye "Sin asignar"), boton "Aplicar" y atajo "Asignar todas las
/// no asignadas a…".
class BulkAssignmentBar extends StatelessWidget {
  final List<PrinterZoneModel> allZones;

  const BulkAssignmentBar({super.key, required this.allZones});

  @override
  Widget build(BuildContext context) {
    final PrinterSettingsController controller =
        Get.find<PrinterSettingsController>();

    return Obx(() {
      final int selectedCount = controller.selectedCategoryIds.length;
      return Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: selectedCount > 0
              ? const Color(0xFF0D47A1).withValues(alpha: 0.08)
              : Colors.grey.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: selectedCount > 0
                ? const Color(0xFF0D47A1).withValues(alpha: 0.4)
                : Colors.grey.shade300,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildHeader(controller, selectedCount),
            const SizedBox(height: 8),
            BulkZoneSelector(
              allZones: allZones,
              onApply: (zoneId, displayName) async {
                await _handleApply(controller, zoneId, displayName);
              },
            ),
            const SizedBox(height: 8),
            _buildAssignAllButton(controller),
          ],
        ),
      );
    });
  }

  Widget _buildHeader(PrinterSettingsController controller, int selectedCount) {
    return Row(
      children: [
        Icon(
          selectedCount > 0
              ? Icons.check_box
              : Icons.check_box_outline_blank,
          color: selectedCount > 0 ? const Color(0xFF0D47A1) : Colors.grey,
          size: 20,
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            selectedCount == 0
                ? 'Selecciona categorias abajo'
                : '$selectedCount categoria(s) seleccionada(s)',
            style: TextStyle(
              fontSize: 13,
              fontWeight:
                  selectedCount > 0 ? FontWeight.bold : FontWeight.normal,
              color: selectedCount > 0
                  ? const Color(0xFF0D47A1)
                  : Colors.black54,
            ),
          ),
        ),
        if (selectedCount > 0)
          TextButton(
            onPressed: controller.clearSelection,
            child: const Text('Limpiar'),
          ),
      ],
    );
  }

  Widget _buildAssignAllButton(PrinterSettingsController controller) {
    return Obx(() {
      final int unassigned = controller.unassignedCategoryIds().length;
      return SizedBox(
        width: double.infinity,
        child: OutlinedButton.icon(
          onPressed: unassigned == 0
              ? null
              : () => showAssignAllUnassignedDialog(allZones),
          icon: const Icon(Icons.playlist_add, size: 18),
          label: Text(
            unassigned == 0
                ? 'Sin categorias sin asignar'
                : 'Asignar todas las no asignadas ($unassigned) a...',
          ),
          style: OutlinedButton.styleFrom(
            foregroundColor: const Color(0xFF0D47A1),
            side: const BorderSide(color: Color(0xFF0D47A1)),
            padding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 10,
            ),
            textStyle: const TextStyle(fontSize: 12),
          ),
        ),
      );
    });
  }

  Future<void> _handleApply(
    PrinterSettingsController controller,
    String zoneId,
    String displayName,
  ) async {
    final List<String> ids = controller.selectedCategoryIds.toList();
    if (ids.isEmpty) {
      ErrorHandler.showErrorDialog('Selecciona al menos una categoria');
      return;
    }
    if (zoneId == _kUnassignedZoneId) {
      await controller.bulkClearAssignments(ids);
      Get.showSnackbar(
        InfoSnackbar(
          'Se quito la asignacion de ${ids.length} categoria(s)',
        ),
      );
    } else {
      await controller.bulkAssignCategoriesToZone(
        categoryIds: ids,
        zoneId: zoneId,
      );
      Get.showSnackbar(
        InfoSnackbar(
          'Asignadas ${ids.length} categoria(s) a "$displayName"',
        ),
      );
    }
  }
}

/// Dropdown con la opcion "Sin asignar" + Caja + zonas custom, y boton
/// "Aplicar" adyacente.
class BulkZoneSelector extends StatefulWidget {
  final List<PrinterZoneModel> allZones;
  final Future<void> Function(String zoneId, String displayName) onApply;

  const BulkZoneSelector({
    super.key,
    required this.allZones,
    required this.onApply,
  });

  @override
  State<BulkZoneSelector> createState() => _BulkZoneSelectorState();
}

class _BulkZoneSelectorState extends State<BulkZoneSelector> {
  String? _selectedZoneId;

  @override
  Widget build(BuildContext context) {
    final PrinterSettingsController controller =
        Get.find<PrinterSettingsController>();
    return Row(
      children: [
        Expanded(
          child: DropdownButtonFormField<String>(
            initialValue: _selectedZoneId,
            isExpanded: true,
            decoration: const InputDecoration(
              labelText: 'Enviar seleccionadas a',
              isDense: true,
              contentPadding:
                  EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              border: OutlineInputBorder(),
            ),
            items: <DropdownMenuItem<String>>[
              const DropdownMenuItem<String>(
                value: _kUnassignedZoneId,
                child: Text(
                  'Sin asignar (impresora principal)',
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              ...widget.allZones.map(
                (z) => DropdownMenuItem<String>(
                  value: z.id ?? kCajaZoneId,
                  child: Text(
                    z.isCaja
                        ? 'Caja (impresora principal)'
                        : (z.name ?? 'Zona'),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
            ],
            onChanged: (v) => setState(() => _selectedZoneId = v),
          ),
        ),
        const SizedBox(width: 8),
        Obx(() {
          final bool hasSelection = controller.selectedCategoryIds.isNotEmpty;
          return ElevatedButton(
            onPressed:
                hasSelection ? () => _handleApply(controller) : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF0D47A1),
              foregroundColor: Colors.white,
              padding:
                  const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            ),
            child: const Text('Aplicar'),
          );
        }),
      ],
    );
  }

  Future<void> _handleApply(PrinterSettingsController controller) async {
    if (_selectedZoneId == null) {
      ErrorHandler.showErrorDialog('Selecciona una zona destino');
      return;
    }
    final String selected = _selectedZoneId!;
    String displayName;
    if (selected == _kUnassignedZoneId) {
      displayName = 'Sin asignar';
    } else {
      final PrinterZoneModel? zone =
          widget.allZones.firstWhereOrNull((z) => z.id == selected);
      if (zone == null) {
        ErrorHandler.showErrorDialog('Zona destino no encontrada');
        return;
      }
      displayName = zone.isCaja ? 'Caja' : (zone.name ?? 'Zona');
    }
    await widget.onApply(selected, displayName);
  }
}
