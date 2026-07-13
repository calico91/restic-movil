import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:restic_movil/app/data/models/price_model.dart';
import 'package:restic_movil/app/data/models/order_model.dart';
import 'package:restic_movil/app/data/models/product_model.dart';
import 'package:restic_movil/app/modules/orders/controllers/orders_controller.dart';
import 'package:restic_movil/app/modules/take_order/views/widgets/add_product_dialog.dart';
import 'package:restic_movil/app/modules/take_order/views/widgets/combo/combo_selection_dialog.dart';
import 'package:restic_movil/app/modules/take_order/views/widgets/combination_selection_dialog.dart';
import 'package:restic_movil/app/modules/take_order/views/widgets/order_summary/order_summary_sheet.dart';
import 'package:restic_movil/core/utils/modals/modal_error.dart';
import 'package:restic_movil/core/utils/widgets/product_selection_widget.dart';

/*
  Hoja modal para agregar productos adicionales a un pedido existente.
  Permite seleccionar productos, ajustar cantidades y agregar comentarios.
  Muestra un botón flotante "Ver Pedido" para revisar, eliminar y confirmar los productos.
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
      child: Stack(
        children: [
          Column(
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
                  padding: const EdgeInsets.only(bottom: 80),
                  child: Obx(() {
                    // Forzar reactividad
                    // ignore: unused_local_variable
                    final _ = controller.tempAdditionalOrderItems.length;

                    return ProductSelectionWidget(
                      categories: controller.categories.toList(),
                      getQuantity: controller.getTempProductQuantity,
                      onIncrement: (product, price) {
                        if (product.productType == 'COMBO') {
                          _showComboDialog(context, product, price);
                        } else {
                          controller.incrementTempProduct(product, price);
                        }
                      },
                      onDecrement: controller.decrementTempProduct,
                      onEdit: (product, price) {
                        if (product.productType == 'COMBO') {
                          _showComboDialog(context, product, price);
                        } else {
                          _showAddProductDialog(product, price);
                        }
                      },
                      onCombine: (product, siblings) =>
                          _showCombinationDialog(context, product, siblings),
                      onDecrementCombination: controller.decrementTempCombination,
                      getCombinationQuantity: controller.getTempCombinationQuantity,
                    );
                  }),
                ),
              ),
            ],
          ),
          // FAB "Ver Pedido (n)" — aparece cuando hay productos seleccionados
          Obx(() {
            if (controller.tempAdditionalOrderItems.isEmpty) {
              return const SizedBox.shrink();
            }
            return Positioned(
              bottom: 20,
              right: 20,
              child: FloatingActionButton.extended(
                onPressed: () => Get.bottomSheet(
                  OrderSummarySheet(
                    externalItems: controller.tempAdditionalOrderItems,
                    externalTotal: () => controller.totalAdditionalAmount,
                    externalRemoveItem: controller.removeTempItem,
                    externalConfirm: () => controller.confirmAddProducts(order),
                    externalConfirmLabel: 'Confirmar Agregar',
                    externalObservationsController:
                        controller.additionalObservationsController,
                  ),
                  isScrollControlled: true,
                ),
                label: Text(
                  'Ver Pedido (${controller.tempAdditionalOrderItems.length})',
                  style: const TextStyle(color: Colors.white),
                ),
                icon: const Icon(Icons.shopping_cart, color: Colors.white),
                backgroundColor: Colors.blue[900],
              ),
            );
          }),
        ],
      ),
    );
  }

  void _showAddProductDialog(ProductModel product, PriceModel? price) {
    final int currentQty = controller.getCommentlessTempProductQuantity(product, price);
    if (currentQty == 0) {
      Get.dialog(const ModalError(
        message: 'Agregue al menos un producto antes de añadir un comentario.',
      ));
      return;
    }
    Get.dialog(
      AddProductDialog(
        product: product,
        price: price,
        currentQuantity: currentQty,
        onConfirm: (comment) =>
            controller.addCommentToTempOrder(product, price, comment),
      ),
    );
  }

  /* Mostrar dialogo de seleccion de combinacion 2x1 */
  void _showCombinationDialog(
      BuildContext context, ProductModel product, List<ProductModel> siblings) {
    Get.dialog(
      CombinationSelectionDialog(
        product: product,
        siblings: siblings,
        onConfirm: (p1, p2, quantity, comment) =>
            controller.addTempCombination(p1, p2, quantity, comment),
      ),
    );
  }

  /* Mostrar dialogo de seleccion de combo */
  void _showComboDialog(
      BuildContext context, ProductModel product, PriceModel? price) {
    Get.dialog(
      ComboSelectionDialog(
        product: product,
        price: price,
        onConfirm: (product, selectedPrice, quantity, comment, comboSelections,
            additionalPrice, previousItem) {
          return controller.addToTempOrder(
            product,
            quantity,
            comment,
            price: selectedPrice,
            comboSelections: comboSelections,
            additionalPrice: additionalPrice,
            replaceItem: previousItem,
          );
        },
      ),
    );
  }
}
