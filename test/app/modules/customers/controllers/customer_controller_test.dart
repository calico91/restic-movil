import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:restic_movil/app/data/models/customer_model.dart';
import 'package:restic_movil/app/data/repositories/customer_repository.dart';
import 'package:restic_movil/app/modules/customers/controllers/customer_controller.dart';

class MockCustomerRepository implements CustomerRepository {
  bool failApiCall = false;
  bool isCreated = false;
  bool isUpdated = false;
  bool isDeleted = false;

  @override
  Future<List<CustomerModel>> getAllCustomers() async {
    if (failApiCall) throw Exception('API Error Customers');
    return [
      CustomerModel(id: '1', name: 'John', lastName: 'Doe', phone: '123456', email: 'john@example.com'),
    ];
  }

  @override
  Future<CustomerModel> createCustomer(CustomerModel customer) async {
    if (failApiCall) throw Exception('Fail Create');
    isCreated = true;
    return customer;
  }

  @override
  Future<CustomerModel> updateCustomer(CustomerModel customer) async {
    if (failApiCall) throw Exception('Fail Update');
    isUpdated = true;
    return customer;
  }

  @override
  Future<void> deleteCustomer(String id) async {
    if (failApiCall) throw Exception('Fail Delete');
    isDeleted = true;
  }

  @override
  Future<CustomerModel> getCustomerById(String id) async {
    if (failApiCall) throw Exception('Fail ID');
    return CustomerModel(id: '1', name: 'John', phone: '123456');
  }
}

class TestCustomerController extends CustomerController {
  @override
  void onReady() {} // Prevent fetching automatically on UI setup
  
  Future<void> testLoadCustomers() async {
    final result = await Get.find<CustomerRepository>().getAllCustomers();
    customers.assignAll(result);
  }
}

void main() {
  group('Pruebas de Controller - CustomerController', () {
    late TestCustomerController controller;
    late MockCustomerRepository mockRepository;

    setUp(() {
      Get.reset();
      Get.testMode = true;
      mockRepository = MockCustomerRepository();
      Get.put<CustomerRepository>(mockRepository);
      controller = Get.put(TestCustomerController());
    });

    testWidgets('Debe cargar clientes correctamente', (tester) async {
      await tester.pumpWidget(const GetMaterialApp(home: Scaffold(body: SizedBox())));
      controller.onInit();
      await controller.testLoadCustomers();

      expect(controller.customers.length, 1);
      expect(controller.customers.first.name, 'John');
    });

    testWidgets('Debe fallar al enviar formulario inválido (submit)', (tester) async {
      await tester.pumpWidget(const GetMaterialApp(home: Scaffold(body: SizedBox())));
      controller.onInit();
      
      // Valores vacíos para required fields 'name' y 'phone'
      controller.form.control('name').value = '';
      controller.form.control('phone').value = '';

      await tester.runAsync(() async {
        await controller.submit();
      });

      expect(controller.form.invalid, true);
      expect(mockRepository.isCreated, false);
    });

    testWidgets('Debe crear cliente si el formulario es válido', (tester) async {
      await tester.pumpWidget(const GetMaterialApp(home: Scaffold(body: SizedBox())));
      controller.onInit();
      
      // Campos requeridos
      controller.form.control('name').value = 'Jane';
      controller.form.control('phone').value = '987654';
      
      controller.isEditing.value = false;

      await tester.runAsync(() async {
        await controller.submit();
      });

      expect(mockRepository.isCreated, true);
      expect(mockRepository.isUpdated, false);
    });

    testWidgets('Debe actualizar cliente en modo edicion', (tester) async {
      await tester.pumpWidget(const GetMaterialApp(home: Scaffold(body: SizedBox())));
      controller.onInit();
      
      controller.openEditForm(CustomerModel(id: '1', name: 'John', phone: '123456'));
      
      // Limpiar modals que dejo openEditForm
      
      expect(controller.isEditing.value, true);

      controller.form.control('name').value = 'John Updated';
      
      await tester.runAsync(() async {
        await controller.submit();
      });

      expect(mockRepository.isUpdated, true);
      expect(mockRepository.isCreated, false);
    });
  });
}
