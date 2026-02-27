import 'package:get/get.dart';
import 'package:restic_movil/app/modules/cash_register/controllers/expenses/expenses_controller.dart';

class ExpensesBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ExpensesController>(() => ExpensesController());
  }
}
