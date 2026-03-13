import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:blue_thermal_printer/blue_thermal_printer.dart';
import '../controllers/printer_settings_controller.dart';
import 'package:restic_movil/core/utils/widgets/custom_scaffold.dart';

class PrinterSettingsView extends GetView<PrinterSettingsController> {
  const PrinterSettingsView({super.key});

  @override
  Widget build(BuildContext context) {
    return CustomScaffold(
      title: 'Configuración de Impresora',
      showBackButton: true,
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildStatusHeader(),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: controller.scanDevices,
              icon: const Icon(Icons.refresh),
              label: const Text('Buscar Dispositivos Vinculados'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF0D47A1),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Dispositivos Emparejados:',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF0D47A1),
              ),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: Obx(
                () => controller.devices.isEmpty
                    ? const Center(
                        child: Text(
                          'No se encontraron dispositivos vinculados. Vincula la impresora desde los ajustes de Bluetooth de tu teléfono.',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.grey),
                        ),
                      )
                    : ListView.builder(
                        itemCount: controller.devices.length,
                        itemBuilder: (context, index) {
                          final device = controller.devices[index];
                          return _buildDeviceCard(device);
                        },
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /* mostrar estado de conexion */
  Widget _buildStatusHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.blue.withValues(alpha: 0.3)),
      ),
      child: Column(
        children: [
          const Icon(Icons.print_outlined, size: 48, color: Color(0xFF0D47A1)),
          const SizedBox(height: 10),
          Obx(
            () => Text(
              controller.isConnected.value
                  ? 'Impresora Conectada'
                  : 'Impresora Desconectada',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: controller.isConnected.value ? Colors.green : Colors.red,
              ),
            ),
          ),
          Obx(() {
            if (controller.isConnected.value &&
                controller.selectedDevice.value != null) {
              return Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Text(
                  'Conectado a ${controller.selectedDevice.value!.name}',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              );
            }
            return const SizedBox.shrink();
          }),
        ],
      ),
    );
  }

  /* construir tarjeta de cada dispositivo bluetooth */
  Widget _buildDeviceCard(BluetoothDevice device) {
    return Obx(() {
      final isDeviceSelected =
          controller.selectedDevice.value?.address == device.address;
      final isConnected = controller.isConnected.value && isDeviceSelected;

      return Card(
        margin: const EdgeInsets.only(bottom: 12),
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
            size: 32,
          ),
          title: Text(
            device.name ?? 'Dispositivo desconocido',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          subtitle: Text(device.address ?? 'Sin dirección MAC'),
          trailing: ElevatedButton(
            onPressed: isConnected
                ? controller.disconnect
                : () => controller.connect(device),
            style: ElevatedButton.styleFrom(
              backgroundColor: isConnected
                  ? Colors.red
                  : const Color(0xFF0D47A1),
              foregroundColor: Colors.white,
            ),
            child: Text(isConnected ? 'Desconectar' : 'Conectar'),
          ),
        ),
      );
    });
  }
}
