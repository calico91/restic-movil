import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:reactive_forms/reactive_forms.dart';
import 'package:restic_movil/app/data/models/order_model.dart';
import 'package:restic_movil/app/data/models/product_model.dart';
import 'package:restic_movil/app/modules/orders/controllers/orders_controller.dart';
import 'package:restic_movil/app/modules/take_order/views/widgets/combo/combo_selection_dialog.dart';
import 'package:restic_movil/core/utils/widgets/product_selection_widget.dart';

/*
  Hoja modal para agregar productos adicionales a un pedido existente.
  Permite seleccionar productos, ajustar cantidades y agregar comentarios.
  Muestra un resumen de los productos seleccionados y el total adicional.
  Al confirmar, agrega los productos al pedido a través del controlador.
*/
class AddProductsSheet extends GetView<OrdersController> {
  final OrderModel order;

  const AddProductsSheet({super.key, required this.order});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: Get.height * 0.9,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Agregar a pedido #${order.orderNumber}',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Get.back(),
                ),
              ],
            ),
          ),
          const Divider(),
          Expanded(
            child: SingleChildScrollView(
              child: Obx(() {
                // Forzar reactividad
                // ignore: unused_local_variable
                final _ = controller.tempAdditionalOrderItems.length;

                return ProductSelectionWidget(
                  categories: controller.categories.toList(),
                  getQuantity: controller.getTempProductQuantity,
                  onIncrement: (product) {
                    if (product.productType == 'COMBO') {
                      _showComboDialog(context, product);
                    } else {
                      controller.incrementTempProduct(product);
                    }
                  },
                  onDecrement: controller.decrementTempProduct,
                  onEdit: (product) {
                    if (product.productType == 'COMBO') {
                      _showComboDialog(context, product);
                    } else {
                      _showAddProductDialog(product);
                    }
                  },
                );
              }),
            ),
          ),
          Obx(() {
            if (controller.tempAdditionalOrderItems.isEmpty) {
              return const SizedBox.shrink();
            }
            return Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 10,
                    offset: const Offset(0, -5),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          '${controller.tempAdditionalOrderItems.length} items',
                          style: TextStyle(color: Colors.grey[600]),
                        ),
                        Text(
                          '\$${controller.totalAdditionalAmount.toStringAsFixed(0)}',
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.blue,
                          ),
                        ),
                      ],
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () => controller.confirmAddProducts(order),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue[900],
                      padding: const EdgeInsets.symmetric(
                        horizontal: 30,
                        vertical: 15,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: const Text(
                      'Agregar',
                      style: TextStyle(color: Colors.white, fontSize: 16),
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  void _showAddProductDialog(ProductModel product) {
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
              controller.addToTempOrder(
                product,
                quantityControl.value ?? 1,
                commentControl.value,
              );
              Get.back(); // Cerrar dialogo
            },
            child: const Text('Agregar'),
          ),
        ],
      ),
    );
  }

  /* Mostrar dialogo de seleccion de combo */
  void _showComboDialog(BuildContext context, ProductModel product) {
    Get.dialog(
      ComboSelectionDialog(
        product: product,
        onConfirm:
            (product, quantity, comment, comboSelections, additionalPrice) {
              controller.addToTempOrder(
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
}
