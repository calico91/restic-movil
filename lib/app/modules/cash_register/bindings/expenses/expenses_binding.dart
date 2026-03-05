import 'package:get/get.dart';
import 'package:restic_movil/app/data/http/base_http_client.dart';
import 'package:restic_movil/app/data/repositories/cash_withdrawals_repository.dart';
import 'package:restic_movil/app/modules/cash_register/controllers/expenses/expenses_controller.dart';

class ExpensesBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<CashWithdrawalsRepository>(
        () => CashWithdrawalsRepository(BaseHttpClient()));
    Get.lazyPut<ExpensesController>(() => ExpensesController());
  }
}
