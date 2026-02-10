import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:reactive_forms/reactive_forms.dart';
import 'package:restic_movil/app/data/models/product_model.dart';
import 'package:restic_movil/app/modules/take_order/controllers/take_order_controller.dart';
import 'package:restic_movil/app/modules/take_order/views/widgets/salon/table_card_widget.dart';
import 'package:restic_movil/app/modules/take_order/views/widgets/take_away_delivery/customer_card_widget.dart';
import 'package:restic_movil/app/modules/take_order/views/widgets/combo/combo_selection_dialog.dart';
import 'package:restic_movil/core/utils/widgets/custom_scaffold.dart';
import 'package:restic_movil/core/utils/widgets/expandable_section.dart';
import 'package:restic_movil/core/utils/widgets/product_selection_widget.dart';

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
        if (origin == 'SALON') {
          return Obx(() {
            if (controller.tables.isNotEmpty) {
              return ExpandableSection(
                title: 'Mesas Disponibles',
                icon: Icons.table_restaurant,
                initiallyExpanded: true,
                content: GridView.builder(
                  padding: EdgeInsets.zero,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
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
              );
            }
            return const SizedBox.shrink();
          });
        } else if (origin == 'TAKE_AWAY' || origin == 'DELIVERY') {
          return const ExpandableSection(
            title: 'Cliente',
            icon: Icons.person,
            initiallyExpanded: true,
            content: CustomerCardWidget(),
          );
        }
        return const SizedBox.shrink();
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
        onConfirm: (product, quantity, comment) {
          controller.addToOrder(product, quantity, comment);
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
            ReactiveTextField(
              formControl: quantityControl,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Cantidad',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 10),
            ReactiveTextField(
              formControl: commentControl,
              decoration: const InputDecoration(
                labelText: 'Comentarios',
                border: OutlineInputBorder(),
              ),
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
                Text(
                  'Total: \$${controller.totalOrderAmount.toStringAsFixed(0)}',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                  ),
                ),
              ],
            ),
            const Divider(),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 10),
              child: ReactiveForm(
                formGroup: controller.form,
                child: ReactiveTextField(
                  formControlName: 'observations',
                  decoration: const InputDecoration(
                    labelText: 'Observaciones generales del pedido',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.comment),
                  ),
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
                    return ListTile(
                      title: Text(
                        '${item.product.name} (x${item.quantity})',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: item.comment != null && item.comment!.isNotEmpty
                          ? Text(
                              'Nota: ${item.comment}',
                              style: const TextStyle(
                                fontStyle: FontStyle.italic,
                                color: Colors.grey,
                              ),
                            )
                          : null,
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text('\$${item.total.toStringAsFixed(0)}'),
                          IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () => controller.removeFromOrder(item),
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
}
