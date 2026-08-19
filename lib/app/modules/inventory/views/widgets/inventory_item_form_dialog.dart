import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:reactive_forms/reactive_forms.dart';
import 'package:restic_movil/app/data/models/inventory_item_model.dart';
import 'package:restic_movil/app/modules/inventory/controllers/inventory_controller.dart';

class InventoryItemFormDialog extends StatelessWidget {
  final InventoryController controller;
  final InventoryItemModel? item;

  const InventoryItemFormDialog({super.key, required this.controller, this.item});

  @override
  Widget build(BuildContext context) {  
    return AlertDialog(
      title: Text(item == null ? 'Nuevo insumo' : 'Editar insumo'),
      content: ReactiveForm(
        formGroup: controller.itemForm,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ReactiveTextField<String>(
                formControlName: 'name',
                decoration: const InputDecoration(labelText: 'Nombre'),
              ),
              const SizedBox(height: 12),
              ReactiveDropdownField<String>(
                formControlName: 'unit',
                decoration: const InputDecoration(labelText: 'Unidad'),
                items: const [
                  DropdownMenuItem(value: 'KG', child: Text('KG')),
                  DropdownMenuItem(value: 'G', child: Text('G')),
                  DropdownMenuItem(value: 'OZ', child: Text('OZ')),
                  DropdownMenuItem(value: 'LB', child: Text('LB')),
                  DropdownMenuItem(value: 'L', child: Text('L')),
                  DropdownMenuItem(value: 'ML', child: Text('ML')),
                  DropdownMenuItem(value: 'UNIT', child: Text('UNIT')),
                  DropdownMenuItem(value: 'CAJA', child: Text('CAJA')),
                  DropdownMenuItem(value: 'DOCENA', child: Text('DOCENA')),
                ],
              ),
              const SizedBox(height: 12),
              if (item == null)
                ReactiveTextField<double>(
                  formControlName: 'currentStock',
                  decoration: const InputDecoration(labelText: 'Stock inicial'),
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  valueAccessor: DoubleValueAccessor(),
                ),
              if (item != null)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.blue.shade200),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Stock actual: ${item?.currentStock ?? 0} ${item?.unit ?? ''}',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'Para modificar el stock usa "Agregar Movimiento" en la pestana de Movimientos.',
                        style: TextStyle(fontSize: 12, color: Colors.black54),
                      ),
                    ],
                  ),
                ),
              const SizedBox(height: 12),
              ReactiveTextField<double>(
                formControlName: 'minStock',
                decoration: const InputDecoration(labelText: 'Stock minimo'),
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                valueAccessor: DoubleValueAccessor(),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(onPressed: () => Get.back(), child: const Text('Cancelar')),
        ElevatedButton(
          onPressed: () => controller.saveItem(itemId: item?.id),
          child: const Text('Guardar'),
        ),
      ],
    );
  }
}
