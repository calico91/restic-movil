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
            _buildPaperSizeSection(),
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
            const SizedBox(height: 5),
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
                        padding: EdgeInsets.zero,
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

  /* construir seccion de seleccion de tamaño de papel */
  Widget _buildPaperSizeSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Tamaño de Papel:',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Color(0xFF0D47A1),
          ),
        ),
        const SizedBox(height: 10),
        Obx(
          () => Row(
            children: [
              Expanded(
                child: _buildSizeOption(
                  size: '58mm',
                  label: '58 mm',
                  description: '32 columnas',
                  isSelected: controller.selectedPrinterSize.value == '58mm',
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildSizeOption(
                  size: '80mm',
                  label: '80 mm',
                  description: '48 columnas',
                  isSelected: controller.selectedPrinterSize.value == '80mm',
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  /* construir tarjeta de opcion de tamaño de papel */
  Widget _buildSizeOption({
    required String size,
    required String label,
    required String description,
    required bool isSelected,
  }) {
    return GestureDetector(
      onTap: () => controller.setPrinterSize(size),
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
