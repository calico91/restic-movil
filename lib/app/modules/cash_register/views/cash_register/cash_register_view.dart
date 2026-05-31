import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:restic_movil/app/modules/cash_register/controllers/cash_register_controller.dart';
import 'package:restic_movil/app/modules/orders/views/widgets/manage_surcharges_sheet.dart';
import 'package:restic_movil/core/utils/modals/global_order_details_modal.dart';
import 'package:restic_movil/core/utils/widgets/date_navigator.dart';
import 'package:restic_movil/core/utils/widgets/global_order_card.dart';
import 'package:restic_movil/core/utils/snackbars/error_snackbar.dart';

class CashRegisterView extends GetView<CashRegisterController> {
  const CashRegisterView({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        DateNavigator(
          selectedDate: controller.selectedDate,
          onPrevious: controller.previousDay,
          onNext: controller.nextDay,
          onDateSelected: controller.changeDate,
        ),
        _buildTabs(),
        Expanded(
          child: Obx(() {
            final orders = controller.currentTab.value == 0
                ? controller.pendingOrders
                : controller.historyOrders;

            return RefreshIndicator(
              onRefresh: () async => controller.currentTab.value == 0
                  ? await controller.loadPendingOrders()
                  : await controller.loadHistoryOrders(),
              child: orders.isEmpty
                  ? ListView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      children: [
                        const SizedBox(height: 50),
                        Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.receipt_long_outlined,
                                size: 64,
                                color: Colors.grey[400],
                              ),
                              const SizedBox(height: 16),
                              Text(
                                controller.currentTab.value == 0
                                    ? 'No hay pedidos pendientes'
                                    : 'No hay historial de pedidos',
                                style: TextStyle(
                                  color: Colors.grey[600],
                                  fontSize: 16,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.only(
                        left: 16,
                        right: 16,
                        top: 16,
                        bottom: 100,
                      ),
                      physics: const AlwaysScrollableScrollPhysics(),
                      itemCount: orders.length,
                      itemBuilder: (context, index) {
                        final order = orders[index];
                        final isCanceled =
                            order.status == 'Anulada';

                        return GlobalOrderCard(
                          order: order,
                          detailsText: 'Detalle Pedido',
                          onDetailsPressed: () => GlobalOrderDetailsModal.show(
                            context: context,
                            order: order,
                            isReadOnly: true,
                          ),
                          actionText: 'Pagar',
                          onActionPressed: controller.currentTab.value == 0
                              ? () => controller.showTransactionModal(order)
                              : null,
                          onManageSurchargesPressed: controller.currentTab.value == 0
                              ? () => Get.bottomSheet(
                                    ManageSurchargesSheet(
                                      order: order,
                                      onSave: controller.saveOrderSurcharges,
                                    ),
                                    isScrollControlled: true,
                                    backgroundColor: Colors.transparent,
                                    enableDrag: true,
                                  )
                              : null,
                          printTooltip: controller.currentTab.value == 0
                              ? 'Imprimir precuenta'
                              : 'Reimprimir factura',
                          // Si está en historial y está anulada, ocultamos la opción de imprimir
                          showPrintButton: !isCanceled,
                          onPrintCustomAction: controller.currentTab.value == 0
                              ? () {
                                  controller.printPrecount(order);
                                }
                              : () {
                                  if (order.transactionId != null) {
                                    controller.reprintInvoice(
                                      order.transactionId!,
                                    );
                                  } else {
                                    Get.showSnackbar(
                                      const ErrorSnackbar(
                                        'No hay factura asociada a este pedido.',
                                      ),
                                    );
                                  }
                                },
                          onCancelPressed: controller.currentTab.value == 0
                              ? () => controller.confirmCancelOrder(order)
                              : null,
                        );
                      },
                    ),
            );
          }),
        ),
      ],
    );
  }

  /*construir las pestañas de pendientes e historial*/
  Widget _buildTabs() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Obx(
        () => Row(
          children: [
            Expanded(
              child: _buildTabButton(
                title: 'Pendientes',
                isSelected: controller.currentTab.value == 0,
                onTap: () => controller.changeTab(0),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _buildTabButton(
                title: 'Historial',
                isSelected: controller.currentTab.value == 1,
                onTap: () => controller.changeTab(1),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /*construir el botón de las pestañas*/
  Widget _buildTabButton({
    required String title,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return InkWell(
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
  }
}
