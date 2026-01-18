import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:reactive_forms/reactive_forms.dart';
import 'package:restic_movil/app/modules/take_order/controllers/take_order_controller.dart';
import 'package:restic_movil/core/utils/widgets/custom_app_bar.dart';

class TakeOrderView extends GetView<TakeOrderController> {
  const TakeOrderView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: CustomAppBar(
        title: 'Tomar Pedido',
        showBackButton: true,
        onBack: controller.goBack,
      ),
      body: Stack(
        children: [
          Container(
            height: 150,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.red, Colors.blue],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              ),
            ),
          ),
          SafeArea(
            child: Container(
              margin: const EdgeInsets.only(top: 10),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
              ),
              child: Obx(() {
                return Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: ReactiveForm(
                    formGroup: controller.form,
                    child: Column(
                      children: [
                        ReactiveDropdownField<String>(
                          formControlName: 'origin',
                          items: controller.originTypes.map((type) {
                            return DropdownMenuItem(
                              value: type.code,
                              child: Text(type.description ?? ''),
                            );
                          }).toList(),
                          decoration: InputDecoration(
                            labelText: 'Origen de pedido',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(15),
                            ),
                            filled: true,
                            fillColor: Colors.grey[100],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }
}
