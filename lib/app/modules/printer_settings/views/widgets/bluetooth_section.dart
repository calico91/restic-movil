import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:blue_thermal_printer/blue_thermal_printer.dart';
import 'package:restic_movil/app/modules/printer_settings/controllers/printer_settings_controller.dart';
import 'status_badge.dart';

/// Contenido de la seccion "Conexion Bluetooth": estado, boton de busqueda
/// y lista de dispositivos vinculados.
class BluetoothSection extends StatelessWidget {
  const BluetoothSection({super.key});

  @override
  Widget build(BuildContext context) {
    final PrinterSettingsController controller =
        Get.find<PrinterSettingsController>();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Obx(() {
          final bool connected = controller.isConnected.value;
          return StatusBadge(
            connected: connected,
            label: connected
                ? 'Conectado a ${controller.selectedDevice.value?.name ?? ''}'
                : controller.isBluetoothOn.value
                    ? 'Bluetooth activo - sin impresora'
                    : 'Bluetooth desactivado',
          );
        }),
        const SizedBox(height: 12),
        ElevatedButton.icon(
          onPressed: controller.scanDevices,
          icon: const Icon(Icons.refresh, size: 20),
          label: const Text('Buscar Dispositivos Vinculados'),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF0D47A1),
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 12),
          ),
        ),
        const SizedBox(height: 12),
        Obx(() {
          if (controller.devices.isEmpty) {
            return const Padding(
              padding: EdgeInsets.symmetric(vertical: 12),
              child: Text(
                'No se encontraron dispositivos vinculados.\n'
                'Vincula la impresora desde los ajustes de Bluetooth.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey, fontSize: 13),
              ),
            );
          }
          return Column(
            children:
                controller.devices.map((d) => BluetoothDeviceCard(d)).toList(),
          );
        }),
      ],
    );
  }
}

/// Tarjeta de un dispositivo Bluetooth emparejado, con accion
/// "Conectar" / "Desconectar".
class BluetoothDeviceCard extends StatelessWidget {
  final BluetoothDevice device;

  const BluetoothDeviceCard(this.device, {super.key});

  @override
  Widget build(BuildContext context) {
    final PrinterSettingsController controller =
        Get.find<PrinterSettingsController>();

    return Obx(() {
      final bool isDeviceSelected =
          controller.selectedDevice.value?.address == device.address;
      final bool isConnected =
          controller.isConnected.value && isDeviceSelected;

      return Card(
        margin: const EdgeInsets.only(bottom: 10),
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(
            color: isConnected ? Colors.green : Colors.transparent,
            width: 2,
          ),
        ),
        child: ListTile(
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 8,
          ),
          leading: Icon(
            Icons.bluetooth,
            color: isConnected ? Colors.green : const Color(0xFF0D47A1),
            size: 30,
          ),
          title: Text(
            device.name ?? 'Dispositivo desconocido',
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
          ),
          subtitle: Text(
            device.address ?? 'Sin direccion MAC',
            style: const TextStyle(fontSize: 12),
          ),
          trailing: ElevatedButton(
            onPressed: isConnected
                ? controller.disconnect
                : () => controller.connect(device),
            style: ElevatedButton.styleFrom(
              backgroundColor:
                  isConnected ? Colors.red : const Color(0xFF0D47A1),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              textStyle: const TextStyle(fontSize: 13),
            ),
            child: Text(isConnected ? 'Desconectar' : 'Conectar'),
          ),
        ),
      );
    });
  }
}
