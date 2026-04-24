import 'package:get/get.dart';
import 'package:restic_movil/app/modules/commands/bindings/commands_binding.dart';
import 'package:restic_movil/app/modules/home/controllers/home_controller.dart';
import '../../orders/bindings/orders_binding.dart';
import '../../cash_register/bindings/cash_register_binding.dart';

class HomeBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<HomeController>(() => HomeController());
    OrdersBinding().dependencies();
    CashRegisterBinding().dependencies();
    CommandsBinding().dependencies();
  }
}
