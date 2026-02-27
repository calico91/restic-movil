import 'package:get/get.dart';
import 'package:restic_movil/app/data/http/base_http_client.dart';
import 'package:restic_movil/app/data/repositories/cashier_repository.dart';
import 'package:restic_movil/app/modules/cash_register/controllers/close_shift/close_shift_controller.dart';

class CloseShiftBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => CashierRepository(Get.find<BaseHttpClient>()));
    Get.lazyPut<CloseShiftController>(
      () => CloseShiftController(
        cashierRepository: Get.find<CashierRepository>(),
      ),
    );
  }
}
