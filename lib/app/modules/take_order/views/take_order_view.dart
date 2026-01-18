import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:reactive_forms/reactive_forms.dart';
import 'package:restic_movil/app/modules/take_order/controllers/take_order_controller.dart';
import 'package:restic_movil/core/utils/widgets/custom_scaffold.dart';

class TakeOrderView extends GetView<TakeOrderController> {
  const TakeOrderView({super.key});

  @override
  Widget build(BuildContext context) {
    return CustomScaffold(
      title: 'Tomar Pedido',
      showBackButton: true,
      onBack: controller.goBack,
      body: Obx(() {
        return Padding(
          padding: const EdgeInsets.all(24.0),
          child: ReactiveForm(
            formGroup: controller.form,
            child: Column(children: [_buildOriginDropdown()]),
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
}
