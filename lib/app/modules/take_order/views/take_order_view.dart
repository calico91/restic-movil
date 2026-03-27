import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:reactive_forms/reactive_forms.dart';
import 'package:restic_movil/app/data/models/product_model.dart';
import 'package:restic_movil/app/data/models/order_item_model.dart';
import 'package:restic_movil/app/data/services/printer_service.dart';
import 'package:restic_movil/app/routes/app_routes.dart';
import 'package:restic_movil/app/modules/take_order/controllers/take_order_controller.dart';
import 'package:restic_movil/app/modules/take_order/views/widgets/salon/table_card_widget.dart';
import 'package:restic_movil/app/modules/take_order/views/widgets/take_away_delivery/customer_card_widget.dart';
import 'package:restic_movil/app/modules/take_order/views/widgets/combo/combo_selection_dialog.dart';
import 'package:restic_movil/core/utils/widgets/custom_scaffold.dart';
import 'package:restic_movil/core/utils/widgets/expandable_section.dart';
import 'package:restic_movil/core/utils/widgets/product_selection_widget.dart';
import 'package:restic_movil/core/utils/inputs/custom_text_field.dart';
import 'package:restic_movil/core/utils/icons/action_icon_button.dart';
import 'package:restic_movil/core/utils/snackbars/error_snackbar.dart';

/*
  Vista principal para tomar pedidos en el restaurante.
  Permite seleccionar el origen del pedido, mesas o clientes, y agregar productos al pedido.
  Muestra un resumen del pedido con opción para confirmar.
*/
class TakeOrderView extends GetView<TakeOrderController> {
  const TakeOrderView({super.key});

  @override
  Widget build(BuildContext context) {
    return CustomScaffold(
      title: 'Tomar Pedido',
      showBackButton: true,
      onBack: controller.goBack,
      actions: [
        Obx(() {
          final printerService = Get.find<PrinterService>();
          final isConnected = printerService.isConnected.value;
          return ActionIconButton(
            icon: Icons.print,
            color: isConnected ? Colors.greenAccent : Colors.redAccent,
            tooltip: 'Configuración de impresora',
            onPressed: () => Get.toNamed(Routes.PRINTER_SETTINGS),
          );
        }),
      ],
      floatingActionButton: _buildFloatingActionButton(context),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ReactiveForm(
              formGroup: controller.form,
              child: _buildOriginSection(),
            ),
            const SizedBox(height: 20),
            _buildSelectionSection(),
            const SizedBox(height: 20),
            _buildProductsSection(),
          ],
        ),
      ),
    );
  }

  /* El botón de acción flotante solo se muestra si hay productos en el pedido actual. 
Al hacer tap, muestra un resumen del pedido con opción para confirmar. */
  Widget _buildFloatingActionButton(BuildContext context) {
    return Obx(() {
      /*El botón de acción flotante solo se muestra si hay productos en 
        el pedido actual.*/
      if (controller.currentOrder.isEmpty) return const SizedBox.shrink();
      return FloatingActionButton.extended(
        onPressed: () => _showOrderSummary(context),
        label: Text(
          'Ver Pedido (${controller.currentOrder.length})',
          style: TextStyle(color: Colors.white),
        ),
        icon: const Icon(Icons.shopping_cart, color: Colors.white),
        backgroundColor: Colors.blue[900],
      );
    });
  }

  /* Dependiendo del origen del pedido, se muestra la sección de mesas o clientes.
     Si el origen es "SALON", se muestran las mesas disponibles para seleccionar. */
  Widget _buildSelectionSection() {
    return StreamBuilder(
      stream: controller.form.control('origin').valueChanges,
      builder: (context, snapshot) {
        final origin = controller.form.control('origin').value;
        if (origin == null) return const SizedBox.shrink();

        return Column(
          children: [
            const ExpandableSection(
              title: 'Cliente',
              icon: Icons.person,
              initiallyExpanded: true,
              content: CustomerCardWidget(),
            ),
            if (origin == 'SALON')
              Obx(() {
                if (controller.tables.isNotEmpty) {
                  return Padding(
                    padding: const EdgeInsets.only(top: 20),
                    child: ExpandableSection(
                      title: 'Mesas Disponibles',
                      icon: Icons.table_restaurant,
                      initiallyExpanded: true,
                      content: GridView.builder(
                        padding: EdgeInsets.zero,
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 3,
                              crossAxisSpacing: 10,
                              mainAxisSpacing: 10,
                              childAspectRatio: 1.0,
                            ),
                        itemCount: controller.tables.length,
                        itemBuilder: (context, index) {
                          final table = controller.tables[index];
                          return TableCardWidget(table: table);
                        },
                      ),
                    ),
                  );
                }
                return const SizedBox.shrink();
              }),
          ],
        );
      },
    );
  }

  /*muestra informacion sobre el origen del pedido  */
  Widget _buildOriginSection() {
    return ExpandableSection(
      title: 'Origen de pedido',
      icon: Icons.storefront,
      initiallyExpanded: true,
      content: Obx(() {
        return Wrap(
          spacing: 16,
          children: controller.originTypes.map((type) {
            return Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                ReactiveRadio<String>(
                  formControlName: 'origin',
                  value: type.code ?? '',
                  activeColor: Colors.blue[900],
                  visualDensity: VisualDensity.compact,
                ),
                GestureDetector(
                  onTap: () =>
                      controller.form.control('origin').value = type.code,
                  child: Text(type.description ?? ''),
                ),
              ],
            );
          }).toList(),
        );
      }),
    );
  }

  /*muestra la seccion de productos */
  Widget _buildProductsSection() {
    return StreamBuilder(
      stream: controller.form.control('origin').valueChanges,
      builder: (context, snapshot) {
        return Obx(() {
          final origin = controller.form.control('origin').value;

          // if (controller.categories.isEmpty || origin == null) {
          if (controller.categories.isEmpty) {
            return const SizedBox.shrink();
          }

          if (origin == 'SALON') {
            if (controller.tables.isEmpty) {
              return const SizedBox.shrink();
            }
          } else if (origin == null) {
            return const SizedBox.shrink();
          }

          return ProductSelectionWidget(
            categories: controller.categories,
            getQuantity: controller.getProductQuantity,
            onIncrement: (product) {
              if (product.productType == 'COMBO') {
                _showComboDialog(context, product);
              } else {
                controller.incrementProduct(product);
              }
            },
            onDecrement: (product) {
              controller.decrementProduct(product);
            },
            onEdit: (product) {
              if (product.productType == 'COMBO') {
                _showComboDialog(context, product);
              } else {
                _showAddProductDialog(context, product);
              }
            },
          );
        });
      },
    );
  }

  /* Mostrar dialogo de seleccion de combo */
  void _showComboDialog(BuildContext context, ProductModel product) {
    Get.dialog(
      ComboSelectionDialog(
        product: product,
        onConfirm:
            (product, quantity, comment, comboSelections, additionalPrice) {
              controller.addToOrder(
                product,
                quantity,
                comment,
                comboSelections: comboSelections,
                additionalPrice: additionalPrice,
              );
            },
      ),
    );
  }

  /*muestra el dialogo para agregar producto al pedido */
  void _showAddProductDialog(BuildContext context, ProductModel product) {
    final quantityControl = FormControl<int>(value: 1);
    final commentControl = FormControl<String>(value: '');

    Get.dialog(
      AlertDialog(
        title: Text('Producto: ${product.name}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CustomReactiveTextField(
              formControl: quantityControl,
              keyboardType: TextInputType.number,
              labelText: 'Cantidad',
            ),
            const SizedBox(height: 10),
            CustomReactiveTextField(
              formControl: commentControl,
              labelText: 'Comentarios',
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              controller.addToOrder(
                product,
                quantityControl.value ?? 1,
                commentControl.value,
              );
            },
            child: const Text('Agregar'),
          ),
        ],
      ),
    );
  }

  /*muestra el resumen del pedido */
  void _showOrderSummary(BuildContext context) {
    if (controller.selectedCustomer.value == null) {
      Get.showSnackbar(const ErrorSnackbar('Se debe seleccionar un cliente.'));
      return;
    }

    if (controller.form.control('origin').value == 'SALON' &&
        controller.selectedTableIds.isEmpty) {
      Get.showSnackbar(const ErrorSnackbar('Se debe seleccionar una mesa.'));
      return;
    }

    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(20),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
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
            ),
            const Divider(),

            // INFORMACIÓN DEL CLIENTE Y MESAS
            Padding(
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
            ),
            const Divider(),

            Padding(
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
            ),
            Flexible(
              child: Obx(() {
                return ListView.builder(
                  shrinkWrap: true,
                  itemCount: controller.currentOrder.length,
                  itemBuilder: (context, index) {
                    final item = controller.currentOrder[index];
                    final comboDetails = _buildComboDetails(item);

                    return ListTile(
                      title: Text(
                        '${item.product.name} (x${item.quantity})',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle:
                          (comboDetails.isNotEmpty ||
                              (item.comment != null &&
                                  item.comment!.isNotEmpty))
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
                                if (item.comment != null &&
                                    item.comment!.isNotEmpty)
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
                );
              }),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue[900],
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                onPressed: () {
                  controller.createOrder();
                },
                child: const Text(
                  'Confirmar Pedido',
                  style: TextStyle(fontSize: 18, color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
      isScrollControlled: true,
    );
  }

  String _buildComboDetails(OrderItemModel item) {
    if (item.comboSelections == null || item.comboSelections!.isEmpty) {
      return '';
    }

    final Map<String, int> counts = {};
    for (var selection in item.comboSelections!) {
      final id = selection['comboOptionId'];
      if (id != null) {
        counts[id] = (counts[id] ?? 0) + 1;
      }
    }

    List<String> details = [];
    if (item.product.comboGroups != null) {
      for (var group in item.product.comboGroups!) {
        if (group.options != null) {
          for (var option in group.options!) {
            if (counts.containsKey(option.id)) {
              final count = counts[option.id];
              final name = option.productName ?? 'Opción';
              details.add('$name ($count)');
            }
          }
        }
      }
    }
    return details.join(' - ');
  }
}
