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
      title: 'Ajustes de Pedidos',
      showBackButton: true,
      resizeToAvoidBottomInset: true,
      body: SingleChildScrollView(
        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ExpandableSection(
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
                    if (!controller.canEdit)
                      const Padding(
                        padding: EdgeInsets.only(top: 8.0, left: 4.0),
                        child: Text(
                          'Solo usuarios con rol ADMINISTRADOR o SUPER pueden modificar este ajuste.',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.redAccent,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ),
                  ],
                );
              }),
            ),
          ],
        ),
      ),
    );
  }
}
