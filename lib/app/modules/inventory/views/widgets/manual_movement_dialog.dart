import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:reactive_forms/reactive_forms.dart';
import 'package:restic_movil/app/modules/inventory/controllers/inventory_controller.dart';

class ManualMovementDialog extends StatelessWidget {
  final InventoryController controller;

  const ManualMovementDialog({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Nuevo movimiento'),
      content: ReactiveForm(
        formGroup: controller.movementForm,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ReactiveDropdownField<String>(
                formControlName: 'inventoryItemId',
                decoration: const InputDecoration(labelText: 'Insumo'),
                items: controller.items
                    .where((item) => item.id != null)
                    .map((item) => DropdownMenuItem(
                          value: item.id,
                          child: Text(item.name ?? '-'),
                        ))
                    .toList(),
              ),
              const SizedBox(height: 12),
              ReactiveDropdownField<String>(
                formControlName: 'type',
                decoration: const InputDecoration(labelText: 'Tipo'),
                items: const [
                  DropdownMenuItem(value: 'PURCHASE', child: Text('Compra')),
                  DropdownMenuItem(value: 'ADJUSTMENT_POSITIVE', child: Text('Ajuste positivo')),
                  DropdownMenuItem(value: 'ADJUSTMENT_NEGATIVE', child: Text('Ajuste negativo')),
                  DropdownMenuItem(value: 'WASTE', child: Text('Merma')),
                  DropdownMenuItem(value: 'INITIAL', child: Text('Stock inicial')),
                ],
              ),
              const SizedBox(height: 12),
              ReactiveTextField<double>(
                formControlName: 'quantity',
                decoration: const InputDecoration(labelText: 'Cantidad'),
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                valueAccessor: DoubleValueAccessor(),
              ),
              const SizedBox(height: 12),
              ReactiveTextField<String>(
                formControlName: 'notes',
                decoration: const InputDecoration(labelText: 'Notas'),
                maxLines: 2,
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(onPressed: () => Get.back(), child: const Text('Cancelar')),
        ElevatedButton(
          onPressed: controller.saveManualMovement,
          child: const Text('Guardar'),
        ),
      ],
    );
  }
}
