import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:restic_movil/app/modules/order_settings/controllers/order_settings_controller.dart';
import 'package:restic_movil/core/utils/widgets/custom_scaffold.dart';
import 'package:restic_movil/core/utils/widgets/expandable_section.dart';

class OrderSettingsView extends GetView<OrderSettingsController> {
  const OrderSettingsView({super.key});

  @override
  Widget build(BuildContext context) {
    return CustomScaffold(
      title: 'Ajustes Generales',
      showBackButton: true,
      resizeToAvoidBottomInset: true,
      body: SingleChildScrollView(
        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildGeneralSection(),
            const SizedBox(height: 16),
            if (controller.canEdit) _buildOrdersSection(),
          ],
        ),
      ),
    );
  }

  /*sección General: modo de vista (lista/grilla) de pedidos, comandas y caja*/
  Widget _buildGeneralSection() {
    return ExpandableSection(
      title: 'General',
      icon: Icons.tune,
      initiallyExpanded: true,
      content: Obx(() {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Elige cómo ver los pedidos en las pantallas de Pedidos, Comandas y Caja. Se guarda en este dispositivo.',
              style: TextStyle(fontSize: 13, color: Colors.black54),
            ),
            const SizedBox(height: 12),
            SegmentedButton<String>(
              segments: const [
                ButtonSegment(
                  value: 'list',
                  icon: Icon(Icons.view_list),
                  label: Text('Lista'),
                ),
                ButtonSegment(
                  value: 'grid',
                  icon: Icon(Icons.grid_view),
                  label: Text('Grilla'),
                ),
              ],
              selected: {controller.homeController.orderViewMode.value},
              onSelectionChanged: (selection) =>
                  controller.setOrderViewMode(selection.first),
            ),
          ],
        );
      }),
    );
  }

  /*sección Pedidos (solo ADMIN/SUPER): filtro de pedidos propios del mesero*/
  Widget _buildOrdersSection() {
    return ExpandableSection(
      title: 'Pedidos',
      icon: Icons.receipt_long,
      initiallyExpanded: true,
      content: Obx(() {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text(
                'Solo ver mis pedidos (meseros)',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
              subtitle: const Padding(
                padding: EdgeInsets.only(top: 4.0),
                child: Text(
                  'Al activar esta opción, los meseros solo verán los pedidos que ellos crearon. Aplica a toda la sucursal.',
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.black54,
                  ),
                ),
              ),
              value: controller.waiterViewOwnOrdersOnly.value,
              onChanged: controller.canEdit
                  ? (val) => controller.setWaiterViewOwnOrdersOnly(val)
                  : null,
            ),
          ],
        );
      }),
    );
  }
}
