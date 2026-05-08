import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:reactive_forms/reactive_forms.dart';
import 'package:restic_movil/app/data/models/price_model.dart';
import 'package:restic_movil/app/data/models/product_model.dart';
import 'package:restic_movil/app/data/services/printer_service.dart';
import 'package:restic_movil/app/routes/app_routes.dart';
import 'package:restic_movil/app/modules/take_order/controllers/take_order_controller.dart';
import 'package:restic_movil/app/modules/take_order/views/widgets/salon/table_card_widget.dart';
import 'package:restic_movil/app/modules/take_order/views/widgets/take_away_delivery/customer_card_widget.dart';
import 'package:restic_movil/app/modules/take_order/views/widgets/combo/combo_selection_dialog.dart';
import 'package:restic_movil/app/modules/take_order/views/widgets/combination_selection_dialog.dart';
import 'package:restic_movil/app/modules/take_order/views/widgets/add_product_dialog.dart';
import 'package:restic_movil/app/modules/take_order/views/widgets/order_summary/order_summary_sheet.dart';
import 'package:restic_movil/app/modules/take_order/views/widgets/search/product_search_bar.dart';
import 'package:restic_movil/app/modules/take_order/views/widgets/search/product_search_results_widget.dart';
import 'package:restic_movil/core/utils/widgets/custom_scaffold.dart';
import 'package:restic_movil/core/utils/widgets/expandable_section.dart';
import 'package:restic_movil/core/utils/widgets/product_selection_widget.dart';
import 'package:restic_movil/core/utils/icons/action_icon_button.dart';
import 'package:restic_movil/core/utils/snackbars/error_snackbar.dart';

/*
  Vista principal para tomar pedidos en el restaurante.
  Permite seleccionar el origen del pedido, mesas o clientes, y agregar productos al pedido.
  Muestra un resumen del pedido con opcion para confirmar.
*/
class TakeOrderView extends GetView<TakeOrderController> {
  const TakeOrderView({super.key});

  @override
  Widget build(BuildContext context) {
    return PopScope(
      // Delegar la decisión al controller; false bloquea el pop nativo
      canPop: false,
      onPopInvokedWithResult: (bool didPop, _) {
        if (!didPop) controller.goBack();
      },
      child: CustomScaffold(
      title: 'Tomar Pedido',
      showBackButton: true,
      onBack: controller.goBack,
      resizeToAvoidBottomInset: true,
      actions: [
        Obx(() {
          final PrinterService printerService = Get.find<PrinterService>();
          final bool isConnected = printerService.isConnected.value ||
              printerService.isNetworkConnected.value;
          return ActionIconButton(
            icon: Icons.print,
            color: isConnected ? Colors.greenAccent : Colors.redAccent,
            tooltip: 'Configuracion de impresora',
            onPressed: () => Get.toNamed(Routes.PRINTER_SETTINGS),
          );
        }),
      ],
      floatingActionButton: _buildFloatingActionButton(context),
      body: SingleChildScrollView(
        padding: const EdgeInsets.only(
          left: 24,
          right: 24,
          top: 24,
          bottom: 120,
        ),
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
      ),
    );
  }

  /* Boton flotante que abre el resumen del pedido cuando hay items. */
  Widget _buildFloatingActionButton(BuildContext context) {
    return Obx(() {
      if (controller.currentOrder.isEmpty) return const SizedBox.shrink();
      return FloatingActionButton.extended(
        onPressed: () => _showOrderSummary(context),
        label: Text(
          'Ver Pedido (${controller.currentOrder.length})',
          style: const TextStyle(color: Colors.white),
        ),
        icon: const Icon(Icons.shopping_cart, color: Colors.white),
        backgroundColor: Colors.blue[900],
      );
    });
  }

  /* Seccion de radios para seleccionar el origen del pedido. */
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

  /* Seccion de cliente y mesas segun el origen seleccionado. */
  Widget _buildSelectionSection() {
    return StreamBuilder(
      stream: controller.form.control('origin').valueChanges,
      builder: (context, snapshot) {
        final String? origin = controller.form.control('origin').value;
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
                        itemBuilder: (context, index) =>
                            TableCardWidget(table: controller.tables[index]),
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

  /* Seccion de busqueda y listado de productos. */
  Widget _buildProductsSection() {
    return StreamBuilder(
      stream: controller.form.control('origin').valueChanges,
      builder: (context, snapshot) {
        return Obx(() {
          final String? origin = controller.form.control('origin').value;

          if (controller.categories.isEmpty) return const SizedBox.shrink();

          if (origin == 'SALON' && controller.tables.isEmpty) {
            return const SizedBox.shrink();
          } else if (origin == null) {
            return const SizedBox.shrink();
          }

          return Column(
            children: [
              const ProductSearchBar(),
              const SizedBox(height: 12),
              if (controller.searchProductQuery.isNotEmpty)
                ProductSearchResultsWidget(
                  onIncrement: (product, price) {
                    // COMBO abre su diálogo; COMBINADO y el resto se agregan individualmente
                    if (product.productType == 'COMBO') {
                      _showComboDialog(context, product, price);
                    } else {
                      controller.incrementProduct(product, price);
                    }
                  },
                  onDecrement: (product, price) =>
                      controller.decrementProduct(product, price),
                  onEdit: (product, price) =>
                      _showAddProductDialog(context, product, price),
                  onCombine: (product, siblings) =>
                      _showCombinationDialog(context, product, siblings),
                  onDecrementCombination: controller.decrementCombination,
                  getCombinationQuantity: controller.getCombinationQuantity,
                )
              else
                ProductSelectionWidget(
                  categories: controller.categories,
                  getQuantity: controller.getProductQuantity,
                  onIncrement: (product, price) {
                    // COMBO abre su diálogo; COMBINADO y el resto se agregan individualmente
                    if (product.productType == 'COMBO') {
                      _showComboDialog(context, product, price);
                    } else {
                      controller.incrementProduct(product, price);
                    }
                  },
                  onDecrement: (product, price) =>
                      controller.decrementProduct(product, price),
                  onEdit: (product, price) {
                    if (product.productType == 'COMBO') {
                      _showComboDialog(context, product, price);
                    } else {
                      _showAddProductDialog(context, product, price);
                    }
                  },
                  onCombine: (product, siblings) =>
                      _showCombinationDialog(context, product, siblings),
                  onDecrementCombination: controller.decrementCombination,
                  getCombinationQuantity: controller.getCombinationQuantity,
                ),
            ],
          );
        });
      },
    );
  }

  /* Abre el dialogo de configuracion de combo. */
  void _showComboDialog(
    BuildContext context,
    ProductModel product,
    PriceModel? price,
  ) {
    Get.dialog(
      ComboSelectionDialog(
        product: product,
        price: price,
        onConfirm: (p, selectedPrice, quantity, comment, comboSelections,
                additionalPrice) =>
            controller.addToOrder(
          p,
          quantity,
          comment,
          price: selectedPrice,
          comboSelections: comboSelections,
          additionalPrice: additionalPrice,
        ),
      ),
    );
  }

  /* Abre el dialogo para seleccionar el acompañante de una combinacion 2x1. */
  void _showCombinationDialog(
    BuildContext context,
    ProductModel product,
    List<ProductModel> siblings,
  ) {
    Get.dialog(
      CombinationSelectionDialog(
        product: product,
        siblings: siblings,
        onConfirm: (p1, p2, comment) => controller.addCombination(p1, p2, comment),
      ),
    );
  }

  /* Abre el dialogo para especificar cantidad y comentarios de un producto. */
  void _showAddProductDialog(
    BuildContext context,
    ProductModel product,
    PriceModel? price,
  ) {
    Get.dialog(
      AddProductDialog(
        product: product,
        price: price,
        onConfirm: (quantity, comment) =>
            controller.addToOrder(product, quantity, comment, price: price),
      ),
    );
  }

  /* Valida y abre el bottom sheet con el resumen del pedido. */
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
      const OrderSummarySheet(),
      isScrollControlled: true,
    );
  }
}
