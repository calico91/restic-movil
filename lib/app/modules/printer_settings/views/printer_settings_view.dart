import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:restic_movil/app/modules/printer_settings/controllers/printer_settings_controller.dart';
import 'package:restic_movil/core/utils/widgets/custom_scaffold.dart';
import 'package:restic_movil/core/utils/widgets/expandable_section.dart';
import 'widgets/bluetooth_section.dart';
import 'widgets/category_assignment_section.dart';
import 'widgets/connection_type_indicator.dart';
import 'widgets/network_section.dart';
import 'widgets/paper_size_section.dart';
import 'widgets/zones_section.dart';

/// Vista principal de Configuracion de Impresora.
/// Compone las distintas secciones como widgets independientes para
/// mantener la logica de cada una aislada y sostenible.
class PrinterSettingsView extends GetView<PrinterSettingsController> {
  const PrinterSettingsView({super.key});

  @override
  Widget build(BuildContext context) {
    return const CustomScaffold(
      title: 'Configuracion de Impresora',
      showBackButton: true,
      resizeToAvoidBottomInset: true,
      body: SingleChildScrollView(
        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ConnectionTypeIndicator(),
            SizedBox(height: 16),
            PaperSizeSection(),
            SizedBox(height: 16),
            ExpandableSection(
              title: 'Conexion Bluetooth',
              icon: Icons.bluetooth,
              initiallyExpanded: false,
              content: BluetoothSection(),
            ),
            ExpandableSection(
              title: 'Conexion por Red (TCP/IP)',
              icon: Icons.wifi,
              initiallyExpanded: false,
              content: NetworkSection(),
            ),
            SizedBox(height: 4),
            ExpandableSection(
              title: 'Zonas de Impresion',
              icon: Icons.workspaces_outlined,
              initiallyExpanded: false,
              content: ZonesSection(),
            ),
            ExpandableSection(
              title: 'Asignar Categorias a Zonas',
              icon: Icons.assignment_turned_in_outlined,
              initiallyExpanded: false,
              content: CategoryAssignmentSection(),
            ),
            SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}
