import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
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
        floatingActionButton: Builder(
          builder: (tabContext) {
            return Obx(() {
              if (!controller.canEdit.value) {
                return const SizedBox.shrink();
              }

              return FloatingActionButton.extended(
                onPressed: () {
                  final int currentTabIndex =
                      DefaultTabController.maybeOf(tabContext)?.index ?? 0;
                  if (currentTabIndex == 1) {
                    controller.openManualMovementForm();
                  } else {
                    controller.openItemForm();
                  }
                },
                backgroundColor: const Color(0xFF0D47A1),
                icon: const Icon(Icons.add, color: Colors.white),
                label: const Text('Agregar', style: TextStyle(color: Colors.white)),
              );
            });
          },
        ),
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
    return Obx(() {
      if (controller.items.isEmpty) {
        return const Center(child: Text('No hay insumos registrados.'));
      }

      return Column(
        children: [
          if (controller.canEdit.value)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
              child: Row(
                children: [
                  Expanded(
                    child: Obx(() => ElevatedButton.icon(
                      onPressed: controller.isExportingItems.value ||
                              controller.items.isEmpty
                          ? null
                          : controller.exportItemsCsv,
                      icon: controller.isExportingItems.value
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Icon(Icons.download, size: 18),
                      label: Text(controller.isExportingItems.value
                          ? 'Exportando...'
                          : 'Exportar CSV'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        foregroundColor: Colors.white,
                      ),
                    )),
                  ),
                ],
              ),
            ),
          Expanded(
            child: RefreshIndicator(
              onRefresh: controller.loadAll,
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: controller.items.length,
                itemBuilder: (_, index) {
                  final item = controller.items[index];
                  return InventoryItemCard(
                    item: item,
                    onViewProducts: item.id != null
                        ? () => controller.showAssociatedProducts(item)
                        : null,
                    onEdit: controller.canEdit.value && item.id != null
                        ? () => controller.openItemForm(item: item)
                        : null,
                    onDelete: controller.canEdit.value && item.id != null
                        ? () => controller.deleteItem(item.id!)
                        : null,
                  );
                },
              ),
            ),
          ),
        ],
      );
    });
  }

  Widget _buildMovementsTab() {
    return Column(
      children: [
        _buildFilterBar(),
        Expanded(
          child: Obx(() {
            if (controller.movements.isEmpty) {
              return Center(
                child: Text(
                  controller.hasActiveFilters.value
                      ? 'No hay movimientos que coincidan con los filtros.'
                      : 'No hay movimientos de stock.',
                ),
              );
            }

            return RefreshIndicator(
              onRefresh: () async => controller.loadAll(),
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: controller.movements.length,
                itemBuilder: (_, index) {
                  return StockMovementCard(movement: controller.movements[index]);
                },
              ),
            );
          }),
        ),
      ],
    );
  }

  Widget _buildFilterBar() {
    final dateFormat = DateFormat('dd/MM/yy');

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        border: Border(bottom: BorderSide(color: Colors.grey.shade300)),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Obx(() => Row(
          children: [
            _buildInsumoDropdown(),
            const SizedBox(width: 8),
            _buildTypeDropdown(),
            const SizedBox(width: 8),
            _buildDateButton(dateFormat),
            if (controller.hasActiveFilters.value) ...[
              const SizedBox(width: 8),
              _buildClearButton(),
            ],
            const SizedBox(width: 8),
            Obx(() => ElevatedButton.icon(
              onPressed: controller.isExportingMovements.value ||
                      controller.movements.isEmpty
                  ? null
                  : controller.exportMovementsCsv,
              icon: controller.isExportingMovements.value
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Icon(Icons.download, size: 18),
              label: Text(controller.isExportingMovements.value
                  ? 'Exportando...'
                  : 'Exportar CSV'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
              ),
            )),
          ],
        )),
      ),
    );
  }

  Widget _buildInsumoDropdown() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade400),
        borderRadius: BorderRadius.circular(8),
        color: Colors.white,
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: controller.filterInventoryItemId.value.isEmpty
              ? null
              : controller.filterInventoryItemId.value,
          hint: const Text('Insumo', style: TextStyle(fontSize: 13)),
          icon: const Icon(Icons.arrow_drop_down, size: 20),
          isDense: true,
          items: [
            const DropdownMenuItem(value: '', child: Text('Todos', style: TextStyle(fontSize: 13))),
            ...controller.items
                .where((i) => i.id != null)
                .map((i) => DropdownMenuItem(value: i.id, child: Text(i.name ?? '-', style: const TextStyle(fontSize: 13)))),
          ],
          onChanged: (v) => controller.setFilterInventoryItem(v),
        ),
      ),
    );
  }

  Widget _buildTypeDropdown() {
    const types = [
      ('', 'Todos'),
      ('PURCHASE', 'Compra / Entrada'),
      ('SALE', 'Venta automatica'),
      ('ADJUSTMENT_POSITIVE', 'Ajuste positivo'),
      ('ADJUSTMENT_NEGATIVE', 'Ajuste negativo'),
      ('WASTE', 'Merma'),
      ('INITIAL', 'Stock inicial'),
    ];

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade400),
        borderRadius: BorderRadius.circular(8),
        color: Colors.white,
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: controller.filterType.value.isEmpty ? '' : controller.filterType.value,
          hint: const Text('Tipo', style: TextStyle(fontSize: 13)),
          icon: const Icon(Icons.arrow_drop_down, size: 20),
          isDense: true,
          items: types
              .map((t) => DropdownMenuItem(value: t.$1, child: Text(t.$2, style: const TextStyle(fontSize: 13))))
              .toList(),
          onChanged: (v) => controller.setFilterType(v),
        ),
      ),
    );
  }

  Widget _buildDateButton(DateFormat dateFormat) {
    final from = controller.filterFromDate.value;
    final to = controller.filterToDate.value;

    String label;
    if (from != null && to != null) {
      label = '${dateFormat.format(from)} - ${dateFormat.format(to)}';
    } else if (from != null) {
      label = 'Desde ${dateFormat.format(from)}';
    } else if (to != null) {
      label = 'Hasta ${dateFormat.format(to)}';
    } else {
      label = 'Fecha';
    }

    return InkWell(
      onTap: () => _selectDateRange(dateFormat),
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade400),
          borderRadius: BorderRadius.circular(8),
          color: Colors.white,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.calendar_month, size: 18, color: Colors.grey.shade700),
            const SizedBox(width: 4),
            Text(label, style: TextStyle(fontSize: 13, color: Colors.grey.shade800)),
          ],
        ),
      ),
    );
  }

  Widget _buildClearButton() {
    return IconButton(
      onPressed: controller.clearFilters,
      icon: const Icon(Icons.filter_alt_off),
      tooltip: 'Limpiar filtros',
      iconSize: 20,
      color: Colors.red.shade700,
      padding: EdgeInsets.zero,
      constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
    );
  }

  Future<void> _selectDateRange(DateFormat dateFormat) async {
    final initialRange = DateTimeRange(
      start: controller.filterFromDate.value ?? DateTime.now().subtract(const Duration(days: 30)),
      end: controller.filterToDate.value ?? DateTime.now(),
    );

    final picked = await showDateRangePicker(
      context: Get.context!,
      initialDateRange: initialRange,
      firstDate: DateTime(2000),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );

    if (picked != null) {
      controller.setDateRange(picked.start, picked.end);
    }
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
