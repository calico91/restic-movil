import 'package:get/get.dart';
import 'package:restic_movil/app/data/http/base_http_client.dart';
import 'package:restic_movil/app/data/repositories/cashier_repository.dart';
import 'package:restic_movil/app/modules/cash_register/controllers/pending_closes/pending_closes_controller.dart';

class PendingClosesBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => CashierRepository(Get.find<BaseHttpClient>()));
    Get.lazyPut<PendingClosesController>(
      () => PendingClosesController(Get.find<CashierRepository>()),
    );
  }
}
