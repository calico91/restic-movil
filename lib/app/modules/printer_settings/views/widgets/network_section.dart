import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:restic_movil/app/modules/printer_settings/controllers/printer_settings_controller.dart';
import 'status_badge.dart';

/// Contenido de la seccion "Conexion por Red (TCP/IP)": estado, campos
/// IP y Puerto, y boton Conectar/Desconectar.
class NetworkSection extends StatelessWidget {
  const NetworkSection({super.key});

  @override
  Widget build(BuildContext context) {
    final PrinterSettingsController controller =
        Get.find<PrinterSettingsController>();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Obx(() {
          final bool connected = controller.isNetworkConnected.value;
          final String ip = controller.networkConfig.value?.ip ?? '';
          final int? port = controller.networkConfig.value?.port;
          return StatusBadge(
            connected: connected,
            label: connected
                ? 'Conectado a $ip:$port'
                : 'Sin impresora de red configurada',
          );
        }),
        const SizedBox(height: 14),
        TextField(
          controller: controller.ipController,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            labelText: 'Direccion IP',
            hintText: '192.168.1.100',
            prefixIcon: const Icon(Icons.router_outlined),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 14,
              vertical: 12,
            ),
          ),
        ),
        const SizedBox(height: 10),
        TextField(
          controller: controller.portController,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            labelText: 'Puerto',
            hintText: '9100',
            prefixIcon: const Icon(Icons.settings_ethernet_outlined),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 14,
              vertical: 12,
            ),
          ),
        ),
        const SizedBox(height: 14),
        Obx(
          () => ElevatedButton.icon(
            onPressed: controller.isNetworkConnected.value
                ? controller.disconnectNetwork
                : controller.connectNetwork,
            icon: Icon(
              controller.isNetworkConnected.value
                  ? Icons.link_off
                  : Icons.link,
              size: 20,
            ),
            label: Text(
              controller.isNetworkConnected.value
                  ? 'Desconectar Impresora de Red'
                  : 'Conectar Impresora de Red',
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: controller.isNetworkConnected.value
                  ? Colors.red
                  : const Color(0xFF0D47A1),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 13),
            ),
          ),
        ),
      ],
    );
  }
}
