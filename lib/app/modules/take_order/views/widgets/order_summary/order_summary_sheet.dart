import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:reactive_forms/reactive_forms.dart';
import 'package:restic_movil/app/data/models/order_item_model.dart';
import 'package:restic_movil/app/modules/take_order/controllers/take_order_controller.dart';
import 'package:restic_movil/app/modules/take_order/views/widgets/add_surcharge_dialog.dart';
import 'package:restic_movil/core/utils/inputs/custom_text_field.dart';

/*
  Contenido del bottom sheet de resumen del pedido.
  Muestra los items, cargos adicionales, observaciones y el botón de confirmar.
*/
class OrderSummarySheet extends GetView<TakeOrderController> {
  const OrderSummarySheet({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(),
          const Divider(),
          _buildClientAndTableInfo(),
          const Divider(),
          _buildObservationsField(),
          Flexible(child: _buildOrderList(context)),
          const SizedBox(height: 20),
          _buildConfirmButton(),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text(
          'Resumen del Pedido',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        Obx(
          () => Text(
            'Total: \$${controller.totalOrderAmount.toStringAsFixed(0)}',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.green,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildClientAndTableInfo() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.person, size: 18, color: Colors.grey),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Cliente: ${controller.selectedCustomer.value?.fullName ?? "No seleccionado"}',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          if (controller.form.control('origin').value == 'SALON' &&
              controller.selectedTableIds.isNotEmpty) ...[
            const SizedBox(height: 4),
            Row(
              children: [
                const Icon(
                  Icons.table_restaurant,
                  size: 18,
                  color: Colors.grey,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Mesa(s): ${controller.tables.where((t) => controller.selectedTableIds.contains(t.id)).map((t) => t.name).join(', ')}',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildObservationsField() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: ReactiveForm(
        formGroup: controller.form,
        child: const CustomReactiveTextField(
          formControlName: 'observations',
          labelText: 'Observaciones generales del pedido',
          prefixIcon: Icon(Icons.comment),
          maxLines: 2,
        ),
      ),
    );
  }

  Widget _buildOrderList(BuildContext context) {
    return Obx(() {
      return ListView(
        shrinkWrap: true,
        children: [
          ListView.builder(
            physics: const NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            itemCount: controller.currentOrder.length,
            itemBuilder: (context, index) {
              final OrderItemModel item = controller.currentOrder[index];
              final String comboDetails = _buildComboDetails(item);
              return ListTile(
                title: Text(
                  '${item.productName} (x${item.quantity})',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: (comboDetails.isNotEmpty ||
                        (item.comment != null && item.comment!.isNotEmpty))
                    ? Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (comboDetails.isNotEmpty)
                            Text(
                              comboDetails,
                              style: TextStyle(
                                color: Colors.grey[800],
                                fontSize: 13,
                              ),
                            ),
                          if (item.comment != null && item.comment!.isNotEmpty)
                            Text(
                              'Nota: ${item.comment}',
                              style: const TextStyle(
                                fontStyle: FontStyle.italic,
                                color: Colors.grey,
                              ),
                            ),
                        ],
                      )
                    : null,
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('\$${item.total.toStringAsFixed(0)}'),
                    IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () {
                        controller.removeFromOrder(item);
                        if (controller.currentOrder.isEmpty) {
                          Get.back();
                        }
                      },
                    ),
                  ],
                ),
              );
            },
          ),
          const Divider(),
          _buildSurchargesSection(context),
        ],
      );
    });
  }

  Widget _buildSurchargesSection(BuildContext context) {
    return Obx(() {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Cargos Adicionales',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              TextButton.icon(
                onPressed: () => Get.dialog(
                  AddSurchargeDialog(
                    onConfirm: controller.addSurcharge,
                  ),
                ),
                icon: const Icon(Icons.add_circle_outline, size: 20),
                label: const Text('Agregar'),
              ),
            ],
          ),
          if (controller.surcharges.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
              child: Text(
                'No hay cargos adicionales.',
                style: TextStyle(
                  color: Colors.grey,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),
          ...controller.surcharges.asMap().entries.map((entry) {
            final int index = entry.key;
            final surcharge = entry.value;
            return ListTile(
              dense: true,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16.0,
                vertical: 0.0,
              ),
              title: Text(surcharge.description),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '\$${surcharge.amount.toStringAsFixed(0)}',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  IconButton(
                    icon: const Icon(
                      Icons.remove_circle_outline,
                      color: Colors.red,
                      size: 20,
                    ),
                    onPressed: () => controller.removeSurcharge(index),
                  ),
                ],
              ),
            );
          }),
        ],
      );
    });
  }

  Widget _buildConfirmButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.blue[900],
          padding: const EdgeInsets.symmetric(vertical: 15),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        onPressed: controller.createOrder,
        child: const Text(
          'Confirmar Pedido',
          style: TextStyle(fontSize: 18, color: Colors.white),
        ),
      ),
    );
  }

  /// Construye el detalle de selecciones de un combo para mostrar en el resumen.
  String _buildComboDetails(OrderItemModel item) {
    if (item.comboSelections == null || item.comboSelections!.isEmpty) {
      return '';
    }

    final Map<String, int> counts = {};
    for (final selection in item.comboSelections!) {
      final String? id = selection['comboOptionId'];
      if (id != null) {
        counts[id] = (counts[id] ?? 0) + 1;
      }
    }

    final List<String> details = [];
    if (item.product.comboGroups != null) {
      for (final group in item.product.comboGroups!) {
        if (group.options != null) {
          for (final option in group.options!) {
            if (counts.containsKey(option.id)) {
              final int? count = counts[option.id];
              final String name = option.productName ?? 'Opción';
              details.add('$name ($count)');
            }
          }
        }
      }
    }
    return details.join(' - ');
  }
}
