import 'package:get/get.dart';
import 'package:reactive_forms/reactive_forms.dart';

class LoginController extends GetxController {
  final form = FormGroup({
    'username': FormControl<String>(validators: [Validators.required]),
    'password': FormControl<String>(validators: [Validators.required]),
  });


  final RxString selectedRole = 'Administrador'.obs;
  final List<String> roles = ['Administrador', 'Mesero', 'Cocinero'];

  void selectRole(String role) {
    selectedRole.value = role;
  }

  Future<void> login() async {
    if (form.valid) {
      print(form.value);
      print('Role: ${selectedRole.value}');
      // Get.offAllNamed(Routes.HOME); 
    } else {
      form.markAllAsTouched();
    }
  }
}
