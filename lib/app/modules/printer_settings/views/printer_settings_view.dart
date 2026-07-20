import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:blue_thermal_printer/blue_thermal_printer.dart';
import '../controllers/printer_settings_controller.dart';
import 'package:restic_movil/app/data/models/printer_zone_model.dart';
import 'package:restic_movil/core/utils/enums/printer_connection_type.dart';
import 'package:restic_movil/core/utils/helpers/error_handler.dart';
import 'package:restic_movil/core/utils/printers/category_printer_resolver.dart';
import 'package:restic_movil/core/utils/snackbars/info_snackbar.dart';
import 'package:restic_movil/core/utils/validators/ip_validator.dart';
import 'package:restic_movil/core/utils/widgets/custom_scaffold.dart';
import 'package:restic_movil/core/utils/widgets/expandable_section.dart';

/// ID reservado para la opcion "Sin asignar" en el dropdown bulk.
/// No es una zona real: solo indica que se debe limpiar la asignacion
/// de las categorias seleccionadas (vuelven a la impresora por defecto).
const String kUnassignedZoneId = '__unassigned__';

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
             ExpandableSection(
              title: 'Conexión Bluetooth',
              icon: Icons.bluetooth,
              initiallyExpanded: false,
              content: _buildBluetoothSection(),
            ),
            ExpandableSection(
              title: 'Conexión por Red (TCP/IP)',
              icon: Icons.wifi,
              initiallyExpanded: false,
              content: _buildNetworkSection(),
            ),
            const SizedBox(height: 4),
            ExpandableSection(
              title: 'Zonas de Impresión',
              icon: Icons.workspaces_outlined,
              initiallyExpanded: false,
              content: _buildZonesSection(),
            ),
            ExpandableSection(
              title: 'Asignar Categorías a Zonas',
              icon: Icons.assignment_turned_in_outlined,
              initiallyExpanded: false,
              content: _buildCategoryAssignmentSection(),
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
  //  Zonas de Impresión
  // ───────────────────────────────────────────────

  Widget _buildZonesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Padding(
          padding: EdgeInsets.only(bottom: 8),
          child: Text(
            'Crea zonas (p. ej. "Jugos", "Caliente") con su IP y puerto. '
            'Luego asigna categorías a cada zona con un toque. '
            'La zona "Caja" siempre equivale a la impresora de red principal.',
            style: TextStyle(fontSize: 12, color: Colors.black54),
          ),
        ),
        _buildCajaZoneCard(),
        const SizedBox(height: 8),
        Obx(() {
          if (controller.zones.isEmpty) {
            return const Padding(
              padding: EdgeInsets.symmetric(vertical: 8),
              child: Text(
                'No hay zonas adicionales configuradas.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey, fontSize: 12),
              ),
            );
          }
          return Column(
            children: controller.zones
                .map((z) => _buildZoneCard(z))
                .toList(),
          );
        }),
        const SizedBox(height: 8),
        ElevatedButton.icon(
          onPressed: () => _openZoneDialog(),
          icon: const Icon(Icons.add, size: 20),
          label: const Text('Agregar Zona'),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF0D47A1),
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 12),
          ),
        ),
      ],
    );
  }

  Widget _buildCajaZoneCard() {
    return Obx(() {
      final PrinterZoneModel? caja = controller.cajaZone;
      return Card(
        margin: const EdgeInsets.only(bottom: 8),
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(
            color: Colors.green.withValues(alpha: 0.5),
            width: 1.5,
          ),
        ),
        child: ListTile(
          leading: const Icon(Icons.point_of_sale, color: Colors.green),
          title: const Text(
            'Caja (impresora principal)',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
          ),
          subtitle: Text(
            caja != null
                ? '${caja.ip}:${caja.port}'
                : 'Configura la impresora de red arriba para activarla',
            style: const TextStyle(fontSize: 12),
          ),
          trailing: const Chip(
            label: Text('Automática'),
            backgroundColor: Color(0x3300C853),
            labelStyle: TextStyle(fontSize: 10, color: Colors.green),
            padding: EdgeInsets.zero,
            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
        ),
      );
    });
  }

  Widget _buildZoneCard(PrinterZoneModel zone) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: const Color(0xFF0D47A1).withValues(alpha: 0.5),
          width: 1.5,
        ),
      ),
      child: ListTile(
        leading: const Icon(Icons.workspaces, color: Color(0xFF0D47A1)),
        title: Text(
          zone.name ?? 'Zona',
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
        ),
        subtitle: Text(
          '${zone.ip}:${zone.port ?? 9100}',
          style: const TextStyle(fontSize: 12),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              tooltip: 'Editar',
              onPressed: () => _openZoneDialog(zone: zone),
              icon: const Icon(Icons.edit, color: Color(0xFF0D47A1), size: 20),
            ),
            IconButton(
              tooltip: 'Eliminar',
              onPressed: () => _confirmDeleteZone(zone),
              icon: const Icon(Icons.delete_outline, color: Colors.red, size: 20),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _openZoneDialog({PrinterZoneModel? zone}) async {
    final TextEditingController nameCtrl =
        TextEditingController(text: zone?.name ?? '');
    final TextEditingController ipCtrl =
        TextEditingController(text: zone?.ip ?? '');
    final TextEditingController portCtrl = TextEditingController(
      text: (zone?.port ?? 9100).toString(),
    );
    final GlobalKey<FormState> formKey = GlobalKey<FormState>();

    final bool? saved = await Get.dialog<bool>(
      AlertDialog(
        title: Text(zone == null ? 'Nueva Zona' : 'Editar Zona'),
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: nameCtrl,
                decoration: const InputDecoration(
                  labelText: 'Nombre',
                  hintText: 'Ej. Jugos, Caliente, Barra',
                ),
                validator: (v) => (v ?? '').trim().isEmpty
                    ? 'Ingresa un nombre'
                    : null,
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: ipCtrl,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'IP',
                  hintText: '192.168.1.101',
                ),
                validator: (v) => IpValidator.validate(v),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: portCtrl,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Puerto'),
                validator: (v) {
                  final int? p = int.tryParse((v ?? '').trim());
                  if (p == null || p < 1 || p > 65535) {
                    return 'Puerto inválido';
                  }
                  return null;
                },
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (!(formKey.currentState?.validate() ?? false)) return;
              final int port = int.parse(portCtrl.text.trim());
              if (zone == null) {
                await controller.addZone(
                  name: nameCtrl.text,
                  ip: ipCtrl.text,
                  port: port,
                );
              } else {
                await controller.updateZone(
                  zoneId: zone.id!,
                  name: nameCtrl.text,
                  ip: ipCtrl.text,
                  port: port,
                );
              }
              Get.back(result: true);
            },
            child: const Text('Guardar'),
          ),
        ],
      ),
    );
    if (saved == true) {
      Get.showSnackbar(
        InfoSnackbar(
          zone == null
              ? 'Zona agregada'
              : 'Zona actualizada',
        ),
      );
    }
  }

  Future<void> _confirmDeleteZone(PrinterZoneModel zone) async {
    final bool? ok = await Get.dialog<bool>(
      AlertDialog(
        title: const Text('Eliminar zona'),
        content: Text(
          '¿Eliminar la zona "${zone.name}"? Las categorías que la usaban '
          'volverán a "Caja".',
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Get.back(result: true),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
    if (ok == true) {
      await controller.deleteZone(zone.id!);
      Get.showSnackbar(const InfoSnackbar('Zona eliminada'));
    }
  }

  // ───────────────────────────────────────────────
  //  Asignacion de categorias a zonas
  // ───────────────────────────────────────────────

  Widget _buildCategoryAssignmentSection() {
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

      final List<PrinterZoneModel> allZones = controller.allZones;
      if (allZones.isEmpty) {
        return const Padding(
          padding: EdgeInsets.symmetric(vertical: 8),
          child: Text(
            'Configura la impresora de red en la sección "Conexión por Red" '
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
              'Selecciona varias categorías y envíalas a una zona con un solo '
              'toque. Las categorías sin asignar imprimirán sus comandas en la '
              'impresora principal (Caja o Bluetooth activo).',
              style: TextStyle(fontSize: 12, color: Colors.black54),
            ),
          ),
          const SizedBox(height: 8),
          _buildBulkAssignmentBar(allZones),
          const SizedBox(height: 8),
          ...controller.categories
              .map((c) => _buildCategoryAssignmentTile(c))
              ,
        ],
      );
    });
  }

  Future<void> _assignAllUnassigned(List<PrinterZoneModel> allZones) async {
    final int pending = controller.unassignedCategoryIds().length;
    if (pending == 0) return;

    String? selectedZoneId;
    await Get.dialog<bool>(
      AlertDialog(
        title: const Text('Asignar todas las no asignadas'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Text(
                'Hay $pending categoría(s) sin zona asignada. Elige la zona '
                'a la que se enviarán todas:',
                style: const TextStyle(fontSize: 13),
              ),
            ),
            StatefulBuilder(
              builder: (ctx, setSt) {
                return DropdownButtonFormField<String>(
                  initialValue: selectedZoneId,
                  isExpanded: true,
                  decoration: const InputDecoration(
                    labelText: 'Zona destino',
                    border: OutlineInputBorder(),
                    isDense: true,
                  ),
                  items: allZones
                      .map(
                        (z) => DropdownMenuItem<String>(
                          value: z.id ?? kCajaZoneId,
                          child: Text(
                            z.isCaja
                                ? 'Caja (impresora principal)'
                                : (z.name ?? 'Zona'),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      )
                      .toList(),
                  onChanged: (v) => setSt(() => selectedZoneId = v),
                );
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (selectedZoneId == null) {
                ErrorHandler.showErrorDialog('Selecciona una zona');
                return;
              }
              final int count = await controller.assignAllUnassignedToZone(
                selectedZoneId!,
              );
              Get.back(result: true);
              Get.showSnackbar(
                InfoSnackbar('Asignadas $count categoría(s)'),
              );
            },
            child: const Text('Asignar'),
          ),
        ],
      ),
    );
  }

  Widget _buildBulkAssignmentBar(List<PrinterZoneModel> allZones) {
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
            Row(
              children: [
                Icon(
                  selectedCount > 0
                      ? Icons.check_box
                      : Icons.check_box_outline_blank,
                  color: selectedCount > 0
                      ? const Color(0xFF0D47A1)
                      : Colors.grey,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    selectedCount == 0
                        ? 'Selecciona categorías abajo'
                        : '$selectedCount categoría(s) seleccionada(s)',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: selectedCount > 0
                          ? FontWeight.bold
                          : FontWeight.normal,
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
            ),
            const SizedBox(height: 8),
            _buildZoneDropdownForBulk(allZones),
            const SizedBox(height: 8),
            Obx(() {
              final int unassigned = controller.unassignedCategoryIds().length;
              return SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: unassigned == 0
                      ? null
                      : () => _assignAllUnassigned(allZones),
                  icon: const Icon(Icons.playlist_add, size: 18),
                  label: Text(
                    unassigned == 0
                        ? 'Sin categorías sin asignar'
                        : 'Asignar todas las no asignadas ($unassigned) a…',
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
            }),
          ],
        ),
      );
    });
  }

  Widget _buildZoneDropdownForBulk(List<PrinterZoneModel> allZones) {
    return _BulkZoneSelector(
      allZones: allZones,
      onApply: (zoneId, displayName) async {
        final List<String> ids = controller.selectedCategoryIds.toList();
        if (ids.isEmpty) {
          ErrorHandler.showErrorDialog('Selecciona al menos una categoría');
          return;
        }
        if (zoneId == kUnassignedZoneId) {
          await controller.bulkClearAssignments(ids);
          Get.showSnackbar(
            InfoSnackbar(
              'Se quitó la asignación de ${ids.length} categoría(s)',
            ),
          );
        } else {
          await controller.bulkAssignCategoriesToZone(
            categoryIds: ids,
            zoneId: zoneId,
          );
          Get.showSnackbar(
            InfoSnackbar(
              'Asignadas ${ids.length} categoría(s) a "$displayName"',
            ),
          );
        }
      },
    );
  }

  Widget _buildCategoryAssignmentTile(cat) {
    final String? catId = cat.id;
    if (catId == null) return const SizedBox.shrink();

    return Obx(() {
      final bool selected = controller.selectedCategoryIds.contains(catId);
      final String zoneName = controller.zoneNameForCategory(catId);
      final bool isCaja = controller.zoneIdForCategory(catId) == kCajaZoneId;

      return Card(
        margin: const EdgeInsets.only(bottom: 6),
        elevation: selected ? 3 : 1,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
          side: BorderSide(
            color: selected
                ? const Color(0xFF0D47A1)
                : Colors.transparent,
            width: selected ? 2 : 0,
          ),
        ),
        child: CheckboxListTile(
          value: selected,
          onChanged: (_) => controller.toggleCategorySelection(catId),
          controlAffinity: ListTileControlAffinity.leading,
          dense: true,
          title: Text(
            cat.name ?? 'Categoría',
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
          ),
          subtitle: Padding(
            padding: const EdgeInsets.only(top: 2),
            child: Row(
              children: [
                Icon(
                  isCaja
                      ? Icons.point_of_sale
                      : Icons.workspaces_outlined,
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
}

class _BulkZoneSelector extends StatefulWidget {
  final List<PrinterZoneModel> allZones;
  final Future<void> Function(String zoneId, String displayName) onApply;

  const _BulkZoneSelector({
    required this.allZones,
    required this.onApply,
  });

  @override
  State<_BulkZoneSelector> createState() => _BulkZoneSelectorState();
}

class _BulkZoneSelectorState extends State<_BulkZoneSelector> {
  String? _selectedZoneId;

  @override
  Widget build(BuildContext context) {
    final PrinterSettingsController controller = Get.find();
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
                value: kUnassignedZoneId,
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
            onPressed: hasSelection
                ? () => _handleApply(controller)
                : null,
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
    if (selected == kUnassignedZoneId) {
      displayName = 'Sin asignar';
    } else {
      final PrinterZoneModel? zone = widget.allZones.firstWhereOrNull(
        (z) => z.id == selected,
      );
      if (zone == null) {
        ErrorHandler.showErrorDialog('Zona destino no encontrada');
        return;
      }
      displayName = zone.isCaja ? 'Caja' : (zone.name ?? 'Zona');
    }
    await widget.onApply(selected, displayName);
  }
}
