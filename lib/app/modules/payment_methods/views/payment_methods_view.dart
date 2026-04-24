import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:restic_movil/app/data/models/payment_method_model.dart';
import 'package:restic_movil/app/modules/payment_methods/controllers/payment_methods_controller.dart';
import 'package:restic_movil/app/modules/payment_methods/views/widgets/payment_method_form_modal.dart';
import 'package:restic_movil/core/utils/buttons/custom_edit_button.dart';
import 'package:restic_movil/core/utils/widgets/custom_scaffold.dart';

class PaymentMethodsView extends GetView<PaymentMethodsController> {
  const PaymentMethodsView({super.key});

  @override
  Widget build(BuildContext context) {
    return CustomScaffold(
      title: 'Métodos de Pago',
      body: Obx(() {
        if (controller.methods.isEmpty) {
          return const Center(child: Text('No hay métodos configurados.'));
        }
        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: controller.methods.length,
          itemBuilder: (context, index) {
            final method = controller.methods[index];
            return Card(
              elevation: 2,
              margin: const EdgeInsets.only(bottom: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: (method.active ?? false)
                      ? const Color(0xFF0D47A1)
                      : Colors.grey,
                  child: Icon(
                    (method.active ?? false) ? Icons.check : Icons.close,
                    color: Colors.white,
                  ),
                ),
                title: Text(
                  method.displayName ?? 'Método sin nombre',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Código: ${method.method ?? "Desconocido"}'),
                    Text('Orden: ${method.displayOrder ?? 0}'),
                  ],
                ),
                trailing: CustomEditButton(
                  onPressed: () => _showEditForm(context, method),
                ),
              ),
            );
          },
        );
      }),
    );
  }

  void _showEditForm(BuildContext context, PaymentMethodModel method) {
    controller.prepareEdit(method);
    Get.bottomSheet(
      PaymentMethodFormModal(method: method),
      isScrollControlled: true,
      enableDrag: true,
      backgroundColor: Colors.transparent,
    );
  }
}
