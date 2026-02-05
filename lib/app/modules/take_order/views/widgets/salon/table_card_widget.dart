import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:restic_movil/app/data/models/table_model.dart';
import 'package:restic_movil/app/modules/take_order/controllers/take_order_controller.dart';

/*
  Widget para mostrar una tarjeta de mesa en la pantalla de toma de pedidos.
  Permite seleccionar o deseleccionar la mesa al hacer tap.
  Cambia su apariencia según si está seleccionada o no.
*/
class TableCardWidget extends GetView<TakeOrderController> {
  final TableModel table;

  const TableCardWidget({required this.table, super.key});

  @override
  Widget build(BuildContext context) {
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
}
