import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:restic_movil/app/modules/printer_settings/controllers/printer_settings_controller.dart';

/// Seccion con las dos opciones de tamano de papel (58mm / 80mm).
/// Al tocar una opcion se persiste via [PrinterSettingsController.setPrinterSize].
class PaperSizeSection extends StatelessWidget {
  const PaperSizeSection({super.key});

  @override
  Widget build(BuildContext context) {
    final PrinterSettingsController controller =
        Get.find<PrinterSettingsController>();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Tamano de Papel:',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Color(0xFF0D47A1),
          ),
        ),
        const SizedBox(height: 10),
        Obx(
          () => Row(
            children: [
              Expanded(
                child: SizeOption(
                  size: '58mm',
                  label: '58 mm',
                  description: '32 columnas',
                  isSelected: controller.selectedPrinterSize.value == '58mm',
                  onTap: () => controller.setPrinterSize('58mm'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: SizeOption(
                  size: '80mm',
                  label: '80 mm',
                  description: '48 columnas',
                  isSelected: controller.selectedPrinterSize.value == '80mm',
                  onTap: () => controller.setPrinterSize('80mm'),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// Tarjeta individual seleccionable de tamano de papel.
class SizeOption extends StatelessWidget {
  final String size;
  final String label;
  final String description;
  final bool isSelected;
  final VoidCallback onTap;

  const SizeOption({
    super.key,
    required this.size,
    required this.label,
    required this.description,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
        decoration: BoxDecoration(
          color: isSelected
              ? const Color(0xFF0D47A1).withValues(alpha: 0.1)
              : Colors.grey.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? const Color(0xFF0D47A1) : Colors.grey.shade300,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Icon(
              isSelected
                  ? Icons.radio_button_checked
                  : Icons.radio_button_unchecked,
              color: isSelected ? const Color(0xFF0D47A1) : Colors.grey,
              size: 22,
            ),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                    color: isSelected
                        ? const Color(0xFF0D47A1)
                        : Colors.grey.shade700,
                  ),
                ),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 12,
                    color: isSelected
                        ? const Color(0xFF0D47A1).withValues(alpha: 0.7)
                        : Colors.grey,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
