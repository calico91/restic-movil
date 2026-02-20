import 'package:get/get.dart';
import 'package:restic_movil/app/data/http/base_http_client.dart';
import 'package:restic_movil/app/data/repositories/cashier_repository.dart';
import 'package:restic_movil/app/modules/cash_register/controllers/open_shift_controller.dart';

class OpenShiftBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<CashierRepository>(() => CashierRepository(BaseHttpClient()));
    Get.lazyPut<OpenShiftController>(
      () => OpenShiftController(Get.find<CashierRepository>()),
    );
  }
}
