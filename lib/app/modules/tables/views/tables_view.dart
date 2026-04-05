import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:restic_movil/app/modules/home/views/widgets/custom_drawer.dart';
import 'package:restic_movil/app/modules/tables/controllers/tables_controller.dart';
import 'package:restic_movil/app/modules/tables/views/widgets/table_form_modal.dart';
import 'package:restic_movil/core/utils/modals/modal_warning.dart';
import 'package:restic_movil/core/utils/widgets/custom_scaffold.dart';

class TablesView extends GetView<TablesController> {
  const TablesView({super.key});

  @override
  Widget build(BuildContext context) {
    return CustomScaffold(
      title: 'Gestión de Mesas',
      drawer: const CustomDrawer(),
      showBackButton: true,
      floatingActionButton: Obx(() {
        if (controller.selectedTableIds.isEmpty) return const SizedBox.shrink();

        final canReserve = controller.canReserveSelected;
        final canRelease = controller.canReleaseSelected;

        if (!canReserve && !canRelease) return const SizedBox.shrink();

        return Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            if (canRelease)
              FloatingActionButton.extended(
                heroTag: 'releaseBtn',
                onPressed: controller.releaseSelectedTables,
                backgroundColor: Colors.green,
                icon: const Icon(Icons.check_circle_outline, color: Colors.white),
                label: Text(
                  'Liberar (${controller.selectedTableIds.length})',
                  style: const TextStyle(color: Colors.white),
                ),
              ),
            if (canRelease && canReserve) const SizedBox(width: 10),
            if (canReserve)
              FloatingActionButton.extended(
                heroTag: 'reserveBtn',
                onPressed: controller.reserveSelectedTables,
                backgroundColor: Colors.blue,
                icon: const Icon(Icons.bookmark_outline, color: Colors.white),
                label: Text(
                  'Reservar (${controller.selectedTableIds.length})',
                  style: const TextStyle(color: Colors.white),
                ),
              ),
          ],
        );
      }),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Listado de Mesas',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF0D47A1),
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: () {
                    controller.prepareCreate();
                    Get.dialog(const TableFormModal());
                  },
                  icon: const Icon(Icons.add, color: Colors.white),
                  label: const Text(
                    'Nueva Mesa',
                    style: TextStyle(color: Colors.white),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFB71C1C),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const Divider(),
          Expanded(
            child: Obx(() {
              if (controller.tables.isEmpty) {
                return const Center(
                  child: Text(
                    'No hay mesas registradas en esta sucursal.',
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                );
              }

              return GridView.builder(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 80), // Extra padding bottom for FAB
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: 1.2,
                ),
                itemCount: controller.tables.length,
                itemBuilder: (context, index) {
                  final table = controller.tables[index];
                  
                  return Obx(() {
                    final isSelected = controller.isTableSelected(table.id!);

                    return Card(
                      elevation: isSelected ? 8 : 4,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                        side: BorderSide(
                          color: isSelected ? Colors.blue.shade900 : Colors.transparent,
                          width: 2,
                        ),
                      ),
                      color: isSelected ? Colors.blue.shade50 : Colors.white,
                      child: InkWell(
                        onLongPress: () {
                          if (table.id != null) {
                            controller.toggleTableSelection(table.id!);
                          }
                        },
                        onTap: () {
                          if (controller.selectedTableIds.isNotEmpty && table.id != null) {
                            // Si ya hay seleccionadas, al tocar agrega o quita en lugar de editar.
                            controller.toggleTableSelection(table.id!);
                          } else {
                            controller.prepareEdit(table);
                            Get.dialog(const TableFormModal());
                          }
                        },
                        borderRadius: BorderRadius.circular(15),
                        child: Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Text(
                                      table.name ?? 'Mesa',
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  if (isSelected)
                                    const Icon(Icons.check_circle, color: Colors.blue)
                                  else
                                    IconButton(
                                      icon: const Icon(
                                        Icons.delete,
                                        color: Colors.red,
                                        size: 20,
                                      ),
                                      onPressed: () {
                                        Get.dialog(
                                          ModalWarning(
                                            title: 'Eliminar Mesa',
                                            message: '¿Está seguro de eliminar esta mesa?',
                                            buttonText: 'Cancelar',
                                            secondaryButtonText: 'Sí, eliminar',
                                            icon: Icons.delete_outline,
                                            iconColor: Colors.red,
                                            onSecondaryAction: () {
                                              Get.back();
                                              if (table.id != null) {
                                                controller.deleteTable(table.id!);
                                              }
                                            },
                                          ),
                                        );
                                      },
                                      constraints: const BoxConstraints(),
                                      padding: EdgeInsets.zero,
                                    ),
                                ],
                              ),
                              const Spacer(),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: controller
                                      .getStatusColor(table.status)
                                      .withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                    color: controller.getStatusColor(
                                      table.status,
                                    ),
                                  ),
                                ),
                                child: Text(
                                  controller.getStatusName(table.status),
                                  style: TextStyle(
                                    color: controller.getStatusColor(
                                      table.status,
                                    ),
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 8),
                              if (table.location != null &&
                                  table.location!.isNotEmpty)
                                Row(
                                  children: [
                                    const Icon(
                                      Icons.location_on,
                                      size: 14,
                                      color: Colors.grey,
                                    ),
                                    const SizedBox(width: 4),
                                    Expanded(
                                      child: Text(
                                        table.location!,
                                        style: const TextStyle(
                                          fontSize: 12,
                                          color: Colors.grey,
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                            ],
                          ),
                        ),
                      ),
                    );
                  });
                },
              );
            }),
          ),
        ],
      ),
    );
  }
}
