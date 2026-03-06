import 'package:get/get.dart';
import 'package:reactive_forms/reactive_forms.dart';
import 'package:restic_movil/app/data/models/customer_model.dart';
import 'package:restic_movil/app/data/repositories/customer_repository.dart';

class CustomerController extends GetxController {
  final CustomerRepository _repository = Get.find();

  final customers = <CustomerModel>[].obs;
  late FormGroup form;

  // Flag para saber si estamos editando
  final isEditing = false.obs;
  String? _editingId;

  // Estado de carga para la vista
  final isLoading = false.obs;

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

  /// Carga los clientes desde el repositorio.
  /// Maneja el estado isLoading.
  Future<void> loadCustomers() async {
    isLoading.value = true;
    try {
      final result = await _repository.getAllCustomers();
      customers.assignAll(result);
    } catch (e) {
      // Propagar el error a la vista is si es necesario o manejarlo localmente
      rethrow;
    } finally {
      isLoading.value = false;
    }
  }

  /// Abre el formulario para crear un nuevo cliente.
  void openCreateForm() {
    isEditing.value = false;
    _editingId = null;
    form.reset();
    Get.toNamed('/customers/form');
  }

  /// Abre el formulario para editar un cliente existente.
  void openEditForm(CustomerModel customer) {
    isEditing.value = true;
    _editingId = customer.id;
    form.patchValue(customer.toJson());
    Get.toNamed('/customers/form');
  }

  /// Envía el formulario.
  /// Lanza excepción si falla.
  Future<void> submit() async {
    if (form.invalid) {
      form.markAllAsTouched();
      // Lanzamos excepción o manejamos como UI necesite. 
      // Por consistencia, si es inválido, no hacemos throw, solo marcamos.
      // Así la UI sabe que no pasó nada. 
      return; 
    }

    final customerData = CustomerModel.fromJson(form.value);

    // Si queremos que la vista maneje el loading, necesitamos que la llamada sea asíncrona pura.
    
    if (isEditing.value && _editingId != null) {
      customerData.id = _editingId;
      await _repository.updateCustomer(customerData);
    } else {
      await _repository.createCustomer(customerData);
    }
    
    await loadCustomers(); // Refrescar lista
  }

  /// Elimina un cliente.
  Future<void> deleteCustomer(String id) async {
    await _repository.deleteCustomer(id);
    customers.removeWhere((element) => element.id == id);
  }
}

