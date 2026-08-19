import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:restic_movil/app/modules/printer_settings/controllers/printer_settings_controller.dart';
import 'package:restic_movil/core/utils/enums/printer_connection_type.dart';

/// Banner superior que muestra que tipo de conexion esta activa
/// (Red o Bluetooth) y el dispositivo/IP correspondiente.
/// Incluye un boton "Prueba" para imprimir una pagina de prueba.
class ConnectionTypeIndicator extends StatelessWidget {
  const ConnectionTypeIndicator({super.key});

  @override
  Widget build(BuildContext context) {
    final PrinterSettingsController controller =
        Get.find<PrinterSettingsController>();

    return Obx(() {
      final bool isNetwork =
          controller.connectionType.value == PrinterConnectionType.network;
      final bool isConnected = isNetwork
          ? controller.isNetworkConnected.value
          : controller.isConnected.value;

      String label;
      if (isConnected) {
        label = isNetwork
            ? 'Red: ${controller.networkConfig.value?.ip ?? ''}'
            : 'Bluetooth: ${controller.selectedDevice.value?.name ?? ''}';
      } else {
        label = 'Sin conexion activa';
      }

      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: isConnected
              ? Colors.green.withValues(alpha: 0.08)
              : Colors.red.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(15),
          border: Border.all(
            color: isConnected
                ? Colors.green.withValues(alpha: 0.35)
                : Colors.red.withValues(alpha: 0.35),
          ),
        ),
        child: Row(
          children: [
            Icon(
              isConnected ? Icons.print : Icons.print_disabled,
              size: 36,
              color: isConnected ? Colors.green : Colors.red,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    isConnected ? 'Impresora Conectada' : 'Sin Impresora',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: isConnected ? Colors.green : Colors.red,
                    ),
                  ),
                  Text(
                    label,
                    style: const TextStyle(fontSize: 13, color: Colors.black54),
                  ),
                ],
              ),
            ),
            if (isConnected)
              OutlinedButton.icon(
                onPressed: controller.printTestPage,
                icon: const Icon(Icons.print_outlined, size: 18),
                label: const Text('Prueba'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xFF0D47A1),
                  side: const BorderSide(color: Color(0xFF0D47A1)),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  textStyle: const TextStyle(fontSize: 13),
                ),
              ),
          ],
        ),
      );
    });
  }
}
