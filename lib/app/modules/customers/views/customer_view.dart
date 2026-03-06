import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:restic_movil/app/data/models/customer_model.dart';
import 'package:restic_movil/app/modules/customers/controllers/customer_controller.dart';
import 'package:restic_movil/core/utils/animations/loading_charging.dart';
import 'package:restic_movil/core/utils/helpers/exception_handler.dart';
import 'package:restic_movil/core/utils/modals/modal_info.dart';
import 'package:restic_movil/core/utils/snackbars/error_snackbar.dart';
import 'package:restic_movil/core/utils/widgets/custom_scaffold.dart';

class CustomerView extends GetView<CustomerController> {
  const CustomerView({super.key});

  @override
  Widget build(BuildContext context) {
    return CustomScaffold(
      title: 'Clientes',
      showBackButton: true,
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: LoadingCharging());
        }

        if (controller.customers.isEmpty) {
          return const Center(child: Text('No hay clientes registrados'));
        }

        return ListView.builder(
          itemCount: controller.customers.length,
          itemBuilder: (context, index) {
            final customer = controller.customers[index];
            return Card(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              elevation: 2,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: Colors.blue[100],
                  child: Text(
                    customer.name?[0].toUpperCase() ?? '?',
                    style: TextStyle(color: Colors.blue[900], fontWeight: FontWeight.bold),
                  ),
                ),
                title: Text(customer.fullName, style: const TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (customer.phone != null)
                      Row(
                        children: [
                          const Icon(Icons.phone, size: 14, color: Colors.grey),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              customer.phone!,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    if (customer.email != null)
                      Row(
                        children: [
                          const Icon(Icons.email, size: 14, color: Colors.grey),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              customer.email!,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                  ],
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit, color: Colors.blue),
                      onPressed: () => controller.openEditForm(customer),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () => _confirmDelete(customer),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      }),
      floatingActionButton: FloatingActionButton(
        onPressed: controller.openCreateForm,
        backgroundColor: Colors.blue[900],
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  void _confirmDelete(CustomerModel customer) {
    if (customer.id == null) return;
    
    Get.dialog(
      ModalInfo(
        title: 'Confirmación',
        message: '¿Está seguro de eliminar a ${customer.fullName}?',
        buttonText: 'Eliminar',
        icon: Icons.warning_amber_rounded,
        iconColor: Get.theme.primaryColor,
        onClose: () {
          Get.back(); // Cierra el modal de confirmación
          _executeDelete(customer.id!);
        },
      ),
    );
  }

  Future<void> _executeDelete(String id) async {
    Get.showOverlay(
      loadingWidget: const LoadingCharging(),
      asyncFunction: () async {
        try {
          await controller.deleteCustomer(id);
          Get.dialog(
            ModalInfo(
              title: 'Éxito',
              message: 'Cliente eliminado correctamente',
              onClose: () => Get.back(),
            ),
          );
        } catch (e) {
          final message = ExceptionHandler.extractMessage(e);
          Get.showSnackbar(ErrorSnackbar(message));
        }
      },
    );
  }
}

