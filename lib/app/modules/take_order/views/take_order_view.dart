import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:reactive_forms/reactive_forms.dart';
import 'package:restic_movil/app/data/models/product_model.dart';
import 'package:restic_movil/app/data/models/table_model.dart';
import 'package:restic_movil/app/modules/take_order/controllers/take_order_controller.dart';
import 'package:restic_movil/core/utils/widgets/custom_scaffold.dart';
import 'package:restic_movil/core/utils/widgets/expandable_section.dart';

class TakeOrderView extends GetView<TakeOrderController> {
  const TakeOrderView({super.key});

  @override
  Widget build(BuildContext context) {
    return CustomScaffold(
      title: 'Tomar Pedido',
      showBackButton: true,
      onBack: controller.goBack,
      floatingActionButton: Obx(() {
        if (controller.currentOrder.isEmpty) return const SizedBox.shrink();
        return FloatingActionButton.extended(
          onPressed: () => _showOrderSummary(context),
          label: Text('Ver Pedido (${controller.currentOrder.length})'),
          icon: const Icon(Icons.shopping_cart),
          backgroundColor: Colors.blue[900],
        );
      }),
      body: Obx(() {
        return SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ReactiveForm(
                formGroup: controller.form,
                child: _buildOriginDropdown(),
              ),
              const SizedBox(height: 20),
              if (controller.tables.isNotEmpty)
                ExpandableSection(
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
                      return _buildTableCard(table);
                    },
                  ),
                ),
              const SizedBox(height: 20),
              StreamBuilder(
                stream: controller.form.control('origin').valueChanges,
                builder: (context, snapshot) {
                  return _buildProductsSection();
                },
              ),
            ],
          ),
        );
      }),
    );
  }

  /*muestra inforamcion sobre el origen del pedido  */
  Widget _buildOriginDropdown() {
    return ReactiveDropdownField<String>(
      formControlName: 'origin',
      items: controller.originTypes.map((type) {
        return DropdownMenuItem(
          value: type.code,
          child: Text(type.description ?? ''),
        );
      }).toList(),
      decoration: InputDecoration(
        labelText: 'Origen de pedido',
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
        filled: true,
        fillColor: Colors.grey[100],
      ),
    );
  }

  /*muestra la tarjeta de la mesa */
  Widget _buildTableCard(TableModel table) {
    return Obx(() {
      final isSelected = controller.selectedTableIds.contains(table.id);
      return GestureDetector(
        onTap: () => controller.toggleTableSelection(table.id!),
        child: Container(
          decoration: BoxDecoration(
            color: isSelected ? Colors.blue[100] : Colors.white,
            borderRadius: BorderRadius.circular(15),
            border: Border.all(
              color: isSelected ? Colors.blue : Colors.transparent,
              width: 2,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 5,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          padding: const EdgeInsets.all(12),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.table_restaurant,
                color: isSelected ? Colors.blue : Colors.grey,
                size: 30,
              ),
              const SizedBox(height: 5),
              Text(
                table.name ?? 'Mesa',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: isSelected ? Colors.blue[900] : Colors.black87,
                ),
              ),
              Text(
                table.location ?? '',
                style: TextStyle(
                  fontSize: 12,
                  color: isSelected ? Colors.blue[700] : Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
      );
    });
  }

  /*muestra la seccion de productos */
  Widget _buildProductsSection() {
    if (controller.categories.isEmpty ||
        controller.form.control('origin').value == null) {
      return const SizedBox.shrink();
    }

    return ExpandableSection(
      title: 'Productos',
      icon: Icons.fastfood,
      content: ListView.builder(
        padding: EdgeInsets.zero,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: controller.categories.length,
        itemBuilder: (context, index) {
          final category = controller.categories[index];
          return ExpansionTile(
            title: Text(
              category.name ?? '',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            childrenPadding: const EdgeInsets.only(left: 16),
            children:
                category.subcategories?.map((subcategory) {
                  return ExpansionTile(
                    title: Text(
                      subcategory.name ?? '',
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                    subtitle: Text(subcategory.description ?? ''),
                    childrenPadding: const EdgeInsets.only(left: 16),
                    children:
                        subcategory.products?.map((product) {
                          return ListTile(
                            title: Text(product.name ?? ''),
                            subtitle: Text(product.description ?? ''),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  '\$${product.price?.amount?.toStringAsFixed(0) ?? '0'}',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.green,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                IconButton(
                                  icon: const Icon(
                                    Icons.add_circle,
                                    color: Colors.blue,
                                  ),
                                  onPressed: () =>
                                      _showAddProductDialog(context, product),
                                ),
                              ],
                            ),
                          );
                        }).toList() ??
                        [],
                  );
                }).toList() ??
                [],
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
                hintText: 'Ej: Sin cebolla',
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
                  // TODO: Implement Logic to Confirm Order
                  Get.back();
                  Get.snackbar(
                    'Pedido',
                    'Logica de confirmación pendiente',
                    snackPosition: SnackPosition.BOTTOM,
                  );
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
