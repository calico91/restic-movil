import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:restic_movil/app/data/models/order_model.dart';
import 'package:restic_movil/app/data/services/printer_service.dart';
import 'package:restic_movil/app/data/services/storage_service.dart';
import 'package:restic_movil/app/modules/home/controllers/home_controller.dart';
import 'package:restic_movil/app/modules/orders/controllers/orders_controller.dart';
import 'package:restic_movil/app/routes/app_routes.dart';
import 'package:restic_movil/core/utils/buttons/custom_submit_button.dart';
import 'package:restic_movil/core/utils/modals/global_order_details_modal.dart';
import 'package:restic_movil/core/utils/modals/modal_error.dart';
import 'package:restic_movil/core/utils/modals/order_actions_sheet.dart';
import 'package:restic_movil/core/utils/printers/tickets/58mm/order_ticket_58mm.dart';
import 'package:restic_movil/core/utils/printers/tickets/58mm/precount_ticket_58mm.dart';
import 'package:restic_movil/core/utils/printers/tickets/80mm/order_ticket_80mm.dart';
import 'package:restic_movil/core/utils/printers/tickets/80mm/precount_ticket_80mm.dart';
import 'package:restic_movil/core/utils/snackbars/info_snackbar.dart';
import 'package:restic_movil/core/utils/widgets/compact_order_card.dart';
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
        _buildOrdersList(context),
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

  /*build lista o grilla de pedidos según el ajuste general (Ajustes Generales)*/
  Widget _buildOrdersList(BuildContext context) => Expanded(
    child: Obx(() {
      final ordersList = controller.currentTab.value == 0
          ? controller.orders
          : controller.finalizedOrders;
      final isGrid =
          Get.find<HomeController>().orderViewMode.value == 'grid';

      return RefreshIndicator(
        onRefresh: () async => controller.currentTab.value == 0
            ? await controller.loadOrders(withOverlay: false)
            : await controller.loadFinalizedOrders(withOverlay: false),
        child: isGrid
            ? GridView.builder(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: EdgeInsets.only(
                  left: 16,
                  right: 16,
                  top: 16,
                  bottom: MediaQuery.of(context).padding.bottom + 10,
                ),
                gridDelegate: orderGridDelegateFor(
                  MediaQuery.sizeOf(context).width - 32,
                ),
                itemCount: ordersList.length,
                itemBuilder: (context, index) =>
                    _buildCompactGridCard(context, ordersList[index]),
              )
            : ListView.builder(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: EdgeInsets.only(
            left: 16,
            right: 16,
            top: 16,
            bottom: MediaQuery.of(context).padding.bottom + 10,
          ),
          itemCount: ordersList.length,
          itemBuilder: (context, index) {
            final order = ordersList[index];
            return _buildFullOrderCard(context, order);
          },
        ),
      );
    }),
  );

  /*tarjeta completa en modo lista (comportamiento actual)*/
  Widget _buildFullOrderCard(BuildContext context, OrderModel order) =>
      GlobalOrderCard(
        order: order,
        categories: controller.categories,
        showCommandaButton: true,
        detailsText: 'Ver Detalles',
        onDetailsPressed: controller.currentTab.value == 0
            ? () => _showOrderDetails(context, order)
            : null,
        actionText: 'Agregar',
        onActionPressed: () => controller.startAddProducts(order),
        onManageSurchargesPressed: () => Get.bottomSheet(
              ManageSurchargesSheet(order: order),
              isScrollControlled: true,
              backgroundColor: Colors.transparent,
              enableDrag: true,
            ),
        printTooltip: 'Imprimir pedido',
      );

  /*tarjeta compacta en modo grilla: el tap abre la hoja de acciones*/
  Widget _buildCompactGridCard(BuildContext context, OrderModel order) {
    final isActive = controller.currentTab.value == 0;
    return CompactOrderCard(
      order: order,
      statusLabel: order.status,
      showTotal: true,
      onTap: () => OrderActionsSheet.show(
        order: order,
        statusLabel: order.status,
        actions: [
          if (isActive)
            OrderAction(
              icon: Icons.visibility_outlined,
              label: 'Ver Detalles',
              onTap: () => _showOrderDetails(context, order),
            ),
          if (isActive)
            OrderAction(
              icon: Icons.add_shopping_cart,
              label: 'Agregar',
              onTap: () => controller.startAddProducts(order),
            ),
          if (isActive)
            OrderAction(
              icon: Icons.edit_note,
              label: 'Gestionar cargos',
              onTap: () => Get.bottomSheet(
                ManageSurchargesSheet(order: order),
                isScrollControlled: true,
                backgroundColor: Colors.transparent,
                enableDrag: true,
              ),
            ),
          OrderAction(
            icon: Icons.kitchen_outlined,
            label: 'Imprimir comanda',
            onTap: () => _printComanda(order),
          ),
          OrderAction(
            icon: Icons.receipt_long_outlined,
            label: 'Imprimir precuenta',
            onTap: () => _printPrecount(order),
          ),
        ],
      ),
    );
  }

  /*imprimir comanda de cocina (mismo flujo que la tarjeta en modo lista)*/
  Future<void> _printComanda(OrderModel order) async {
    final printerService = Get.find<PrinterService>();
    if (!printerService.isConnected.value &&
        !printerService.isNetworkConnected.value) {
      Get.dialog(const ModalError(message: 'Impresora no conectada'));
      return;
    }
    Get.showSnackbar(const InfoSnackbar('Enviando comanda a imprimir...'));
    final is80mm = printerService.printerSize.value == '80mm';
    final details = order.details;
    final cats = controller.categories;
    if (cats.isNotEmpty && details != null && details.isNotEmpty) {
      await printerService.printComandaMultiPrinterFromDetails(
        order: order,
        details: details,
        categories: cats,
        ticketBuilder: (o, filteredDetails) => is80mm
            ? OrderTicket80mm(order: o, filteredDetails: filteredDetails)
            : OrderTicket58mm(order: o, filteredDetails: filteredDetails),
      );
    } else {
      await printerService.printTicket(
        is80mm ? OrderTicket80mm(order: order) : OrderTicket58mm(order: order),
      );
    }
  }

  /*imprimir precuenta con la propina por defecto guardada*/
  Future<void> _printPrecount(OrderModel order) async {
    final printerService = Get.find<PrinterService>();
    if (!printerService.isConnected.value &&
        !printerService.isNetworkConnected.value) {
      Get.dialog(const ModalError(message: 'Impresora no conectada'));
      return;
    }
    Get.showSnackbar(const InfoSnackbar('Enviando precuenta a imprimir...'));
    final storage = Get.find<StorageService>();
    final tipStr = await storage.getDefaultTipPercentage() ?? '0';
    final tip = double.tryParse(tipStr) ?? 0.0;
    final is80mm = printerService.printerSize.value == '80mm';
    await printerService.printTicket(
      is80mm
          ? PrecountTicket80mm(order: order, tipPercentage: tip)
          : PrecountTicket58mm(order: order, tipPercentage: tip),
    );
  }

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
