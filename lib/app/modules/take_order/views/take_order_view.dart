import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:reactive_forms/reactive_forms.dart';
import 'package:restic_movil/app/data/models/table_model.dart';
import 'package:restic_movil/app/modules/take_order/controllers/take_order_controller.dart';
import 'package:restic_movil/core/utils/widgets/custom_scaffold.dart';
import 'package:restic_movil/core/utils/widgets/expandable_section.dart';

class TakeOrderView extends GetView<TakeOrderController> {
  const TakeOrderView({super.key});

  @override
  Widget build(BuildContext context) {
    return CustomScaffold(
      title: 'Tomar Pedido',
      showBackButton: true,
      onBack: controller.goBack,
      body: Obx(() {
        return SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ReactiveForm(
                formGroup: controller.form,
                child: _buildOriginDropdown(),
              ),
              const SizedBox(height: 20),
              if (controller.tables.isNotEmpty)
                ExpandableSection(
                  title: 'Mesas Disponibles',
                  initiallyExpanded: true,
                  content: GridView.builder(
                    padding: EdgeInsets.zero,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3,
                          crossAxisSpacing: 10,
                          mainAxisSpacing: 10,
                          childAspectRatio: 1.0,
                        ),
                    itemCount: controller.tables.length,
                    itemBuilder: (context, index) {
                      final table = controller.tables[index];
                      return _buildTableCard(table);
                    },
                  ),
                ),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildOriginDropdown() {
    return ReactiveDropdownField<String>(
      formControlName: 'origin',
      items: controller.originTypes.map((type) {
        return DropdownMenuItem(
          value: type.code,
          child: Text(type.description ?? ''),
        );
      }).toList(),
      decoration: InputDecoration(
        labelText: 'Origen de pedido',
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
        filled: true,
        fillColor: Colors.grey[100],
      ),
    );
  }

  Widget _buildTableCard(TableModel table) {
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
