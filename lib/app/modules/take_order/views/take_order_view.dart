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
          label: Text(
            'Ver Pedido (${controller.currentOrder.length})',
            style: TextStyle(color: Colors.white),
          ),
          icon: const Icon(Icons.shopping_cart, color: Colors.white),
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
                child: _buildOriginSection(),
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
    final origin = controller.form.control('origin').value;

    if (controller.categories.isEmpty || origin == null) {
      return const SizedBox.shrink();
    }

    if (origin == 'SALON' && controller.tables.isEmpty) {
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
                          return Container(
                            margin: const EdgeInsets.only(bottom: 8),
                            decoration: BoxDecoration(
                              border: Border(
                                bottom: BorderSide(
                                  color: Colors.grey[200]!,
                                  width: 1,
                                ),
                              ),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          product.name ?? '',
                                          style: const TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                        if (product.description != null)
                                          Text(
                                            product.description!,
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: Colors.grey[600],
                                            ),
                                          ),
                                        const SizedBox(height: 4),
                                        Text(
                                          '\$${product.price?.amount?.toStringAsFixed(0) ?? '0'}',
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: Colors.green,
                                            fontSize: 14,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Row(
                                    children: [
                                      IconButton(
                                        onPressed: () => _showAddProductDialog(
                                          context,
                                          product,
                                        ),
                                        icon: const Icon(
                                          Icons.edit_note,
                                          color: Colors.orange,
                                        ),
                                        tooltip: 'Agregar con notas',
                                      ),
                                      Container(
                                        decoration: BoxDecoration(
                                          color: Colors.grey[100],
                                          borderRadius: BorderRadius.circular(
                                            20,
                                          ),
                                        ),
                                        child: Row(
                                          children: [
                                            IconButton(
                                              icon: const Icon(
                                                Icons.remove,
                                                color: Colors.red,
                                                size: 20,
                                              ),
                                              onPressed: () => controller
                                                  .decrementProduct(product),
                                              constraints: const BoxConstraints(
                                                minWidth: 36,
                                                minHeight: 36,
                                              ),
                                              padding: EdgeInsets.zero,
                                            ),
                                            Obx(
                                              () => Text(
                                                '${controller.getProductQuantity(product)}',
                                                style: const TextStyle(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ),
                                            IconButton(
                                              icon: const Icon(
                                                Icons.add,
                                                color: Colors.green,
                                                size: 20,
                                              ),
                                              onPressed: () => controller
                                                  .incrementProduct(product),
                                              constraints: const BoxConstraints(
                                                minWidth: 36,
                                                minHeight: 36,
                                              ),
                                              padding: EdgeInsets.zero,
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
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
