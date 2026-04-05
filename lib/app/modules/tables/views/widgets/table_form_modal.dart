import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:reactive_forms/reactive_forms.dart';
import 'package:restic_movil/app/data/models/table_status_model.dart';
import 'package:restic_movil/app/modules/tables/controllers/tables_controller.dart';
import 'package:restic_movil/core/utils/buttons/custom_submit_button.dart';
import 'package:restic_movil/core/utils/inputs/custom_text_field.dart';

class TableFormModal extends GetView<TablesController> {
  const TableFormModal({super.key});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Obx(() => Text(
                controller.isEditing.value ? 'Editar Mesa' : 'Nueva Mesa',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF0D47A1),
                ),
              )),
              const SizedBox(height: 20),
              ReactiveForm(
                formGroup: controller.tableForm,
                child: Column(
                  children: [
                    const CustomReactiveTextField<String>(
                      formControlName: 'name',
                      labelText: 'Nombre o Número de Mesa',
                    ),
                    const SizedBox(height: 15),
                    ReactiveDropdownField<String>(
                      formControlName: 'status',
                      decoration: InputDecoration(
                        labelText: 'Estado',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        prefixIcon: const Icon(Icons.flag),
                      ),
                      items: controller.statuses.map((TableStatusDTO status) {
                        return DropdownMenuItem<String>(
                          value: status.name,
                          child: Text(status.description),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 15),
                    const CustomReactiveTextField<String>(
                      formControlName: 'location',
                      labelText: 'Ubicación (opcional)',
                    ),
                    const SizedBox(height: 15),
                    Obx(() {
                      if (!controller.isEditing.value) return const SizedBox.shrink();
                      
                      return const Column(
                        children: [
                          /* 
                           Se muestra exclusivamente cuando la mesa ya existe para poder 
                           actualizar su identificador de ordenamiento interno (tableNumber)
                          */
                          CustomReactiveTextField<int>(
                            formControlName: 'tableNumber',
                            labelText: 'Número de Orden de la Mesa',
                            keyboardType: TextInputType.number,
                          ),
                          SizedBox(height: 15),
                        ],
                      );
                    }),
                    const SizedBox(height: 5),
                    ReactiveFormConsumer(
                      builder: (context, form, child) {
                        return CustomSubmitButton(
                          text: 'Guardar',
                          onPressed: controller.saveTable,
                          backgroundColor: const Color(0xFF0D47A1),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
