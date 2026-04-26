import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:restic_movil/app/data/models/order_model.dart';
import 'package:restic_movil/app/modules/orders/controllers/orders_controller.dart';
import 'package:restic_movil/app/routes/app_routes.dart';
import 'package:restic_movil/core/utils/buttons/custom_submit_button.dart';
import 'package:restic_movil/core/utils/modals/global_order_details_modal.dart';
import 'package:restic_movil/core/utils/widgets/date_navigator.dart';
import 'package:restic_movil/core/utils/widgets/global_order_card.dart';
import 'package:restic_movil/app/modules/orders/views/widgets/manage_surcharges_sheet.dart';

class OrdersView extends GetView<OrdersController> {
  const OrdersView({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildSearchBar(),
        const SizedBox(height: 10),
        DateNavigator(
          selectedDate: controller.selectedDate,
          onPrevious: controller.previousDay,
          onNext: controller.nextDay,
          onDateSelected: controller.changeDate,
        ),
        _buildTabs(),
        const SizedBox(height: 10),
        Obx(
          () => controller.currentTab.value == 0
              ? _buildCreateOrderButton()
              : const SizedBox.shrink(),
        ),
        const SizedBox(height: 20),
        _buildOrdersList(),
      ],
    );
  }

  /*build pestañas de filtros*/
  Widget _buildTabs() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Obx(
        () => Row(
          children: [
            Expanded(
              child: _buildTabButton(
                title: 'Activos',
                isSelected: controller.currentTab.value == 0,
                onTap: () => controller.changeTab(0),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _buildTabButton(
                title: 'Finalizados',
                isSelected: controller.currentTab.value == 1,
                onTap: () => controller.changeTab(1),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /*build boton de pestaña*/
  Widget _buildTabButton({
    required String title,
    required bool isSelected,
    required VoidCallback onTap,
  }) => InkWell(
    onTap: onTap,
    borderRadius: BorderRadius.circular(30),
    child: Container(
      padding: const EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(
        color: isSelected ? Colors.blue[900] : Colors.white,
        borderRadius: BorderRadius.circular(30),
        border: Border.all(
          color: isSelected ? Colors.blue[900]! : Colors.grey[300]!,
        ),
        boxShadow: isSelected
            ? [
                BoxShadow(
                  color: Colors.blue.withValues(alpha: 0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ]
            : null,
      ),
      alignment: Alignment.center,
      child: Text(
        title,
        style: TextStyle(
          color: isSelected ? Colors.white : Colors.grey[600],
          fontWeight: FontWeight.bold,
        ),
      ),
    ),
  );

  /*build barra de busqueda*/
  Widget _buildSearchBar() => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 15),
    child: Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.5),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: TextField(
        controller: controller.searchController,
        decoration: const InputDecoration(
          hintText: 'mesa o nombre del cliente',
          prefixIcon: Icon(Icons.search, color: Colors.blue),
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(vertical: 15),
        ),
      ),
    ),
  );

  /*build boton crear pedido*/
  Widget _buildCreateOrderButton() => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 40.0),
    child: CustomSubmitButton(
      text: 'Crear pedido',
      onPressed: () {
        Get.toNamed(Routes.TAKE_ORDER);
      },
      backgroundColor: Colors.green[600],
    ),
  );

  /*build lista de pedidos*/
  Widget _buildOrdersList() => Expanded(
    child: Obx(() {
      final ordersList = controller.currentTab.value == 0
          ? controller.orders
          : controller.finalizedOrders;

      return RefreshIndicator(
        onRefresh: () async => controller.currentTab.value == 0
            ? await controller.loadOrders(withOverlay: false)
            : await controller.loadFinalizedOrders(withOverlay: false),
        child: ListView.builder(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.only(
            left: 16,
            right: 16,
            top: 16,
            bottom: 100, // Espacio extra para la barra de navegación
          ),
          itemCount: ordersList.length,
          itemBuilder: (context, index) {
            final order = ordersList[index];
            return GlobalOrderCard(
              order: order,
              detailsText: 'Ver Detalles',
              onDetailsPressed: controller.currentTab.value == 0
                  ? () => _showOrderDetails(context, order)
                  : null,
              actionText: 'Agregar',
              onActionPressed: () => controller.startAddProducts(order),
              onManageSurchargesPressed: controller.currentTab.value == 0
                  ? () => Get.bottomSheet(
                        ManageSurchargesSheet(order: order),
                        isScrollControlled: true,
                        backgroundColor: Colors.transparent,
                        enableDrag: true,
                      )
                  : null,
              printTooltip: 'Imprimir pedido',
            );
          },
        ),
      );
    }),
  );

  /*mostrar modal de detalles de pedido*/
  void _showOrderDetails(BuildContext context, OrderModel order) {
    GlobalOrderDetailsModal.show(
      context: context,
      order: order,
      availableStatuses: controller.orderDetailStatuses,
      onUpdateStatus: controller.updateDetailsStatus,
      getStatusDescription: controller.getDetailStatusDescription,
    );
  }
}
