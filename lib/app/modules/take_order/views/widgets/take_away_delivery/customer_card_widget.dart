import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:restic_movil/app/modules/take_order/controllers/take_order_controller.dart';
import 'package:restic_movil/app/modules/take_order/views/widgets/take_away_delivery/customer_selection_modal.dart';

/*
  Widget para mostrar la información del cliente seleccionado en la pantalla de toma de pedido.
  Si no hay cliente seleccionado, muestra un mensaje invitando a seleccionar uno.
  Al hacer tap, abre el modal de selección de cliente.
*/
class CustomerCardWidget extends GetView<TakeOrderController> {
  const CustomerCardWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        controller.searchCustomers('');
        Get.bottomSheet(
          const CustomerSelectionModal(),
          isScrollControlled: true,
          ignoreSafeArea: false,
        );
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade300),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 5,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Obx(() {
          final customer = controller.selectedCustomer.value;
          if (customer == null) {
            return const Column(
              children: [
                Icon(Icons.person_add, size: 40, color: Colors.grey),
                SizedBox(height: 8),
                Text(
                  'Seleccione un cliente',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey,
                  ),
                ),
              ],
            );
          }
          /* Si hay un cliente seleccionado, muestra su información */
          return Row(
            children: [
              CircleAvatar(
                backgroundColor: Colors.blue[900],
                child: Text(
                  customer.name?[0].toUpperCase() ?? '?',
                  style: const TextStyle(color: Colors.white),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      customer.fullName,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    Text(
                      customer.phone ?? 'Sin teléfono',
                      style: TextStyle(color: Colors.grey.shade600),
                    ),
                  ],
                ),
              ),
            ],
          );
        }),
      ),
    );
  }
}
