import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:blue_thermal_printer/blue_thermal_printer.dart';
import '../controllers/printer_settings_controller.dart';
import 'package:restic_movil/core/utils/enums/printer_connection_type.dart';
import 'package:restic_movil/core/utils/widgets/custom_scaffold.dart';
import 'package:restic_movil/core/utils/widgets/expandable_section.dart';

class PrinterSettingsView extends GetView<PrinterSettingsController> {
  const PrinterSettingsView({super.key});

  @override
  Widget build(BuildContext context) {
    return CustomScaffold(
      title: 'Configuración de Impresora',
      showBackButton: true,
      resizeToAvoidBottomInset: true,
      body: SingleChildScrollView(
        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildConnectionTypeIndicator(),
            const SizedBox(height: 16),
            _buildPaperSizeSection(),
            const SizedBox(height: 16),
            Obx(
              () => ExpandableSection(
                title: 'Conexión Bluetooth',
                icon: Icons.bluetooth,
                initiallyExpanded:
                    controller.connectionType.value ==
                    PrinterConnectionType.bluetooth,
                content: _buildBluetoothSection(),
              ),
            ),
            Obx(
              () => ExpandableSection(
                title: 'Conexión por Red (TCP/IP)',
                icon: Icons.wifi,
                initiallyExpanded:
                    controller.connectionType.value ==
                    PrinterConnectionType.network,
                content: _buildNetworkSection(),
              ),
            ),
            const SizedBox(height: 4),
            ExpandableSection(
              title: 'Impresoras por Categoría',
              icon: Icons.category_outlined,
              initiallyExpanded: false,
              content: _buildCategoryPrinterSection(),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  // ───────────────────────────────────────────────
  //  Indicador de transporte activo
  // ───────────────────────────────────────────────

  /* mostrar qué tipo de conexión está activa actualmente */
  Widget _buildConnectionTypeIndicator() {
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
        label = 'Sin conexión activa';
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

  // ───────────────────────────────────────────────
  //  Tamaño de papel
  // ───────────────────────────────────────────────

  /* construir sección de selección de tamaño de papel */
  Widget _buildPaperSizeSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Tamaño de Papel:',
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

  /* construir tarjeta de opción de tamaño de papel */
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

  // ───────────────────────────────────────────────
  //  Sección Bluetooth
  // ───────────────────────────────────────────────

  /* construir el contenido de la sección de conexión Bluetooth */
  Widget _buildBluetoothSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Obx(() {
          final bool connected = controller.isConnected.value;
          return _buildStatusBadge(
            connected: connected,
            label: connected
                ? 'Conectado a ${controller.selectedDevice.value?.name ?? ''}'
                : controller.isBluetoothOn.value
                    ? 'Bluetooth activo – sin impresora'
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
                'No se encontraron dispositivos vinculados.\nVincula la impresora desde los ajustes de Bluetooth.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey, fontSize: 13),
              ),
            );
          }
          return Column(
            children: controller.devices
                .map((d) => _buildDeviceCard(d))
                .toList(),
          );
        }),
      ],
    );
  }

  /* construir tarjeta de cada dispositivo Bluetooth emparejado */
  Widget _buildDeviceCard(BluetoothDevice device) {
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
            device.address ?? 'Sin dirección MAC',
            style: const TextStyle(fontSize: 12),
          ),
          trailing: ElevatedButton(
            onPressed: isConnected
                ? controller.disconnect
                : () => controller.connect(device),
            style: ElevatedButton.styleFrom(
              backgroundColor: isConnected ? Colors.red : const Color(0xFF0D47A1),
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

  // ───────────────────────────────────────────────
  //  Sección Red TCP/IP
  // ───────────────────────────────────────────────

  /* construir el contenido de la sección de conexión por red */
  Widget _buildNetworkSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Obx(() {
          final bool connected = controller.isNetworkConnected.value;
          final String ip = controller.networkConfig.value?.ip ?? '';
          final int? port = controller.networkConfig.value?.port;
          return _buildStatusBadge(
            connected: connected,
            label: connected
                ? 'Conectado a $ip:$port'
                : 'Sin impresora de red configurada',
          );
        }),
        const SizedBox(height: 14),
        // Campo IP
        TextField(
          controller: controller.ipController,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            labelText: 'Dirección IP',
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
        // Campo Puerto
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
        // Botón Conectar / Desconectar
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

  // ───────────────────────────────────────────────
  //  Helpers compartidos
  // ───────────────────────────────────────────────

  /* construir badge de estado de conexión (conectado / desconectado) */
  Widget _buildStatusBadge({required bool connected, required String label}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: connected
            ? Colors.green.withValues(alpha: 0.1)
            : Colors.grey.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: connected
              ? Colors.green.withValues(alpha: 0.4)
              : Colors.grey.shade300,
        ),
      ),
      child: Row(
        children: [
          Icon(
            connected ? Icons.circle : Icons.circle_outlined,
            size: 12,
            color: connected ? Colors.green : Colors.grey,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 13,
                color: connected ? Colors.green.shade700 : Colors.grey,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /* construir la seccion de impresoras asignadas por categoria */
  Widget _buildCategoryPrinterSection() {
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
            'No hay categorías disponibles.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey, fontSize: 13),
          ),
        );
      }

      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Padding(
            padding: EdgeInsets.only(bottom: 8),
            child: Text(
              'Asigna una impresora de red específica por categoría.\n'
              'Los productos sin categoría específica se imprimirán en la impresora por defecto.',
              style: TextStyle(fontSize: 12, color: Colors.black54),
            ),
          ),
          ...controller.categories.map((cat) => _buildCategoryPrinterCard(cat)),
        ],
      );
    });
  }

  /* construir tarjeta de configuracion de impresora para una categoria */
  Widget _buildCategoryPrinterCard(dynamic cat) {
    final String? catId = cat.id;
    if (catId == null) return const SizedBox.shrink();

    final bool hasSpecificPrinter =
        cat.printerIp != null && (cat.printerIp as String).isNotEmpty;
    final List<TextEditingController>? controllers =
        controller.categoryControllers[catId];
    if (controllers == null) return const SizedBox.shrink();

    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: hasSpecificPrinter
              ? const Color(0xFF0D47A1).withValues(alpha: 0.5)
              : Colors.transparent,
          width: hasSpecificPrinter ? 1.5 : 0,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Icon(
                  Icons.category,
                  size: 20,
                  color: hasSpecificPrinter
                      ? const Color(0xFF0D47A1)
                      : Colors.grey,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    cat.name ?? 'Categoría',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      color: hasSpecificPrinter
                          ? const Color(0xFF0D47A1)
                          : Colors.black87,
                    ),
                  ),
                ),
                if (hasSpecificPrinter)
                  Chip(
                    label: const Text('Configurada'),
                    backgroundColor:
                        const Color(0xFF0D47A1).withValues(alpha: 0.1),
                    labelStyle: const TextStyle(
                      fontSize: 11,
                      color: Color(0xFF0D47A1),
                    ),
                    padding: EdgeInsets.zero,
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
              ],
            ),
            const SizedBox(height: 10),
            TextField(
              controller: controllers[0],
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'IP Impresora',
                hintText: '192.168.1.101',
                prefixIcon: const Icon(Icons.router_outlined, size: 20),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 10,
                ),
                isDense: true,
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: controllers[1],
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Puerto',
                hintText: '9100',
                prefixIcon: const Icon(Icons.settings_ethernet_outlined, size: 20),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 10,
                ),
                isDense: true,
              ),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => controller.saveCategoryPrinter(catId),
                    icon: const Icon(Icons.save_outlined, size: 18),
                    label: const Text('Guardar'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF0D47A1),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      textStyle: const TextStyle(fontSize: 13),
                    ),
                  ),
                ),
                if (hasSpecificPrinter) ...[
                  const SizedBox(width: 8),
                  OutlinedButton.icon(
                    onPressed: () => controller.removeCategoryPrinter(catId),
                    icon: const Icon(Icons.link_off, size: 18),
                    label: const Text('Quitar'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.red,
                      side: const BorderSide(color: Colors.red),
                      padding: const EdgeInsets.symmetric(
                        vertical: 10,
                        horizontal: 12,
                      ),
                      textStyle: const TextStyle(fontSize: 13),
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}
