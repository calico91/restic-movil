import 'package:get/get.dart';
import 'package:restic_movil/app/data/http/base_http_client.dart';
import 'package:restic_movil/app/data/repositories/cash_withdrawals_repository.dart';
import 'package:restic_movil/app/data/repositories/cashier_repository.dart';
import 'package:restic_movil/app/modules/cash_register/controllers/withdrawals_history/withdrawals_history_controller.dart';

class WithdrawalsHistoryBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => CashWithdrawalsRepository(Get.find<BaseHttpClient>()));
    Get.lazyPut(() => CashierRepository(Get.find<BaseHttpClient>()));
    Get.lazyPut<WithdrawalsHistoryController>(
      () => WithdrawalsHistoryController(
        Get.find<CashWithdrawalsRepository>(),
        Get.find<CashierRepository>(),
      ),
    );
  }
}
