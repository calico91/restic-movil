import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:restic_movil/app/modules/take_order/controllers/take_order_controller.dart';

/* Un widget modal que permite a los usuarios seleccionar un cliente de una lista. 
Incluye una barra de búsqueda para filtrar clientes por nombre o número de teléfono.
*/
class CustomerSelectionModal extends GetView<TakeOrderController> {
  const CustomerSelectionModal({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Seleccionar Cliente',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 16),
          TextField(
            decoration: InputDecoration(
              hintText: 'Buscar por nombre o teléfono...',
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16),
            ),
            onChanged: controller.searchCustomers,
          ),
          const SizedBox(height: 16),
          Flexible(
            child: Obx(() {
              if (controller.filteredCustomers.isEmpty) {
                return const Center(
                  child: Padding(
                    padding: EdgeInsets.all(20),
                    child: Text('No se encontraron clientes'),
                  ),
                );
              }
              return ListView.builder(
                shrinkWrap: true,
                itemCount: controller.filteredCustomers.length,
                itemBuilder: (context, index) {
                  final customer = controller.filteredCustomers[index];
                  return ListTile(
                    leading: CircleAvatar(
                      backgroundColor: Colors.blue[100],
                      child: Text(
                        customer.name?[0].toUpperCase() ?? '?',
                        style: TextStyle(color: Colors.blue[900]),
                      ),
                    ),
                    title: Text(customer.fullName),
                    subtitle: Text(customer.phone ?? 'Sin teléfono'),
                    onTap: () {
                      controller.selectCustomer(customer);
                      Get.back();
                    },
                  );
                },
              );
            }),
          ),
        ],
      ),
    );
  }
}
