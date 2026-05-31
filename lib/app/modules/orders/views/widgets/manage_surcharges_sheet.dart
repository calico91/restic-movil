import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:reactive_forms/reactive_forms.dart';
import 'package:restic_movil/app/data/models/order_model.dart';
import 'package:restic_movil/app/data/models/order_surcharge_model.dart';
import 'package:restic_movil/app/modules/orders/controllers/orders_controller.dart';
import 'package:restic_movil/core/utils/formatters/currency_formatter.dart';
import 'package:restic_movil/core/utils/formatters/thousands_separator_input_formatter.dart';
import 'package:restic_movil/core/utils/inputs/custom_text_field.dart';

class ManageSurchargesSheet extends StatelessWidget {
  final OrderModel order;
  // Callback opcional para guardar cargos; si es null usa OrdersController
  final Future<void> Function(String, List<dynamic>)? onSave;
  final OrdersController controller = Get.find();

  ManageSurchargesSheet({super.key, required this.order, this.onSave});

  @override
  Widget build(BuildContext context) {
    final RxList<OrderSurchargeModel> localSurcharges =
        List<OrderSurchargeModel>.from(order.surcharges ?? []).obs;

    final fb = FormGroup({
      'description': FormControl<String>(validators: [Validators.required]),
      'amount': FormControl<String>(validators: [Validators.required]),
    });

    void addSurcharge() {
      if (fb.valid) {
        final amountString = fb.control('amount').value.toString().replaceAll(RegExp(r'[^0-9]'), '');
        final amount = double.tryParse(amountString) ?? 0.0;
        final description = fb.control('description').value.toString();
        if (amount > 0) {
          localSurcharges.add(OrderSurchargeModel(description: description, amount: amount));
          fb.reset();
        }
      } else {
        fb.markAllAsTouched();
      }
    }

    return Container(
      height: Get.height * 0.8,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(topLeft: Radius.circular(20), topRight: Radius.circular(20)),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.blue[900],
              borderRadius: const BorderRadius.only(topLeft: Radius.circular(20), topRight: Radius.circular(20)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Gestionar Cargos Adicionales', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                IconButton(icon: const Icon(Icons.close, color: Colors.white), onPressed: () => Get.back()),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: ReactiveForm(
              formGroup: fb,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    flex: 2,
                    child: CustomReactiveTextField(
                      formControlName: 'description',
                      labelText: 'Descripción',
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    flex: 2,
                    child: CustomReactiveTextField(
                      formControlName: 'amount',
                      labelText: 'Monto',
                      keyboardType: TextInputType.number,
                      inputFormatters: [ThousandsSeparatorInputFormatter()],
                      prefixText: '\$ ',
                    ),
                  ),
                  const SizedBox(width: 10),
                  Container(
                    margin: const EdgeInsets.only(top: 8),
                    decoration: BoxDecoration(
                      color: Colors.green,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.add, color: Colors.white),
                      onPressed: addSurcharge,
                    ),
                  )
                ],
              ),
            ),
          ),
          const Divider(),
          Expanded(
            child: Obx(() => ListView.builder(
                  itemCount: localSurcharges.length,
                  itemBuilder: (context, index) {
                    final s = localSurcharges[index];
                    return ListTile(
                      title: Text(s.description),
                      subtitle: Text(CurrencyFormatter.toCurrency(s.amount)),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () => localSurcharges.removeAt(index),
                      ),
                    );
                  },
                )),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: SizedBox(
               width: double.infinity,
               child: ElevatedButton(
                 style: ElevatedButton.styleFrom(
                   backgroundColor: Colors.blue[900],
                   padding: const EdgeInsets.symmetric(vertical: 16),
                   shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                 ),
                 onPressed: () {
                    if (order.id != null) {
                      final saveCallback = onSave ?? controller.saveOrderSurcharges;
                      saveCallback(order.id!, localSurcharges.toList());
                    }
                 },
                 child: const Text('Guardar Cargos', style: TextStyle(fontSize: 16, color: Colors.white)),
               )
            )
          )
        ],
      ),
    );
  }
}
