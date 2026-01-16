import 'package:get/get.dart';
import '../controllers/cash_register_controller.dart';

class CashRegisterBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<CashRegisterController>(
      () => CashRegisterController(),
    );
  }
}
