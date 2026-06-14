import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:restic_movil/app/modules/inventory/controllers/inventory_controller.dart';
import 'package:restic_movil/app/modules/inventory/views/widgets/inventory_item_card.dart';
import 'package:restic_movil/app/modules/inventory/views/widgets/stock_movement_card.dart';
import 'package:restic_movil/core/utils/widgets/custom_scaffold.dart';

class InventoryView extends GetView<InventoryController> {
  const InventoryView({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: CustomScaffold(
        title: 'Inventario',
        floatingActionButton: Obx(() {
          if (!controller.canEdit.value) {
            return const SizedBox.shrink();
          }

          return FloatingActionButton.extended(
            onPressed: () {
              if (DefaultTabController.of(context).index == 1) {
                controller.openManualMovementForm();
              } else {
                controller.openItemForm();
              }
            },
            backgroundColor: const Color(0xFF0D47A1),
            icon: const Icon(Icons.add, color: Colors.white),
            label: const Text('Agregar', style: TextStyle(color: Colors.white)),
          );
        }),
        body: Column(
          children: [
            const TabBar(
              labelColor: Color(0xFF0D47A1),
              unselectedLabelColor: Colors.grey,
              indicatorColor: Color(0xFF0D47A1),
              tabs: [
                Tab(text: 'Insumos'),
                Tab(text: 'Movimientos'),
                Tab(text: 'Alertas'),
              ],
            ),
            Expanded(
              child: Obx(
                () => TabBarView(
                  children: [
                    _buildItemsTab(),
                    _buildMovementsTab(),
                    _buildAlertsTab(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildItemsTab() {
    if (controller.items.isEmpty) {
      return const Center(child: Text('No hay insumos registrados.'));
    }

    return RefreshIndicator(
      onRefresh: controller.loadAll,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: controller.items.length,
        itemBuilder: (_, index) {
          final item = controller.items[index];
          return InventoryItemCard(
            item: item,
            onEdit: controller.canEdit.value && item.id != null
                ? () => controller.openItemForm(item: item)
                : null,
            onDelete: controller.canEdit.value && item.id != null
                ? () => controller.deleteItem(item.id!)
                : null,
          );
        },
      ),
    );
  }

  Widget _buildMovementsTab() {
    if (controller.movements.isEmpty) {
      return const Center(child: Text('No hay movimientos de stock.'));
    }

    return RefreshIndicator(
      onRefresh: controller.loadAll,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: controller.movements.length,
        itemBuilder: (_, index) {
          return StockMovementCard(movement: controller.movements[index]);
        },
      ),
    );
  }

  Widget _buildAlertsTab() {
    if (controller.alerts.isEmpty) {
      return const Center(child: Text('Sin alertas de stock.'));
    }

    return RefreshIndicator(
      onRefresh: controller.loadAll,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: controller.alerts.length,
        itemBuilder: (_, index) {
          return InventoryItemCard(item: controller.alerts[index]);
        },
      ),
    );
  }
}
