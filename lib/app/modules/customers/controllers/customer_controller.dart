import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:reactive_forms/reactive_forms.dart';
import 'package:restic_movil/app/data/models/customer_model.dart';
import 'package:restic_movil/app/data/repositories/customer_repository.dart';
import 'package:restic_movil/core/utils/helpers/exception_handler.dart';
import 'package:restic_movil/core/utils/modals/modal_info.dart';
import 'package:restic_movil/core/utils/animations/loading_charging.dart';
import 'package:restic_movil/core/utils/snackbars/error_snackbar.dart';

class CustomerController extends GetxController {
  final CustomerRepository _repository = Get.find();

  final customers = <CustomerModel>[].obs;
  late FormGroup form;

  final isEditing = false.obs;
  String? _editingId;

  @override
  void onInit() {
    super.onInit();
    _initForm();
  }

  @override
  void onReady() {
    super.onReady();
    loadCustomers();
  }

  void _initForm() {
    form = FormGroup({
      'name': FormControl<String>(validators: [Validators.required]),
      'lastName': FormControl<String>(),
      'document': FormControl<String>(),
      'phone': FormControl<String>(validators: [Validators.required]),
      'email': FormControl<String>(validators: [Validators.email]),
      'address': FormControl<String>(),
      'notes': FormControl<String>(),
    });
  }

  Future<void> loadCustomers() async {
    Get.showOverlay(
      loadingWidget: const LoadingCharging(),
      asyncFunction: () async {
        try {
          final result = await _repository.getAllCustomers();
          customers.assignAll(result);
        } catch (e) {
          final message = ExceptionHandler.extractMessage(e);
          Get.showSnackbar(ErrorSnackbar(message));
        }
      },
    );
  }

  void openCreateForm() {
    isEditing.value = false;
    _editingId = null;
    form.reset();
    Get.toNamed('/customers/form');
  }

  void openEditForm(CustomerModel customer) {
    isEditing.value = true;
    _editingId = customer.id;
    form.patchValue(customer.toJson());
    Get.toNamed('/customers/form');
  }

  Future<void> submit() async {
    if (form.invalid) {
      form.markAllAsTouched();
      return;
    }

    Get.showOverlay(
      loadingWidget: const LoadingCharging(),
      asyncFunction: () async {
        try {
          final customerData = CustomerModel.fromJson(form.value);

          if (isEditing.value && _editingId != null) {
            customerData.id = _editingId;
            await _repository.updateCustomer(customerData);
            Get.dialog(
              ModalInfo(
                title: 'Éxito',
                message: 'Cliente actualizado correctamente',
                onClose: () {
                  Get.back(); // Cerrar modal
                  Get.back(); // Cerrar formulario
                  loadCustomers(); // Recargar lista
                },
              ),
            );
          } else {
            await _repository.createCustomer(customerData);
            Get.dialog(
              ModalInfo(
                title: 'Éxito',
                message: 'Cliente creado correctamente',
                onClose: () {
                  Get.back(); // Cerrar modal
                  Get.back(); // Cerrar formulario
                  loadCustomers(); // Recargar lista
                },
              ),
            );
          }
        } catch (e) {
          final message = ExceptionHandler.extractMessage(e);
          Get.showSnackbar(ErrorSnackbar(message));
        }
      },
    );
  }

  Future<void> deleteCustomer(String id) async {
    Get.dialog(
      ModalInfo(
        title: 'Confirmación',
        message: '¿Está seguro de eliminar este cliente?',
        buttonText: 'Eliminar',
        icon: Icons.warning_amber_rounded,
        iconColor:
            // ignore: use_build_context_synchronously
            Get.theme.primaryColor,
        onClose: () async {
          Get.back(); // Cerrar confirmación

          Get.showOverlay(
            loadingWidget: const LoadingCharging(),
            asyncFunction: () async {
              try {
                await _repository.deleteCustomer(id);
                customers.removeWhere((element) => element.id == id);
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
        },
      ),
    );
  }
}
