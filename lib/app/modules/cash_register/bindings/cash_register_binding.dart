import 'package:get/get.dart';
import 'package:restic_movil/app/data/http/base_http_client.dart';
import 'package:restic_movil/app/data/repositories/orders_repository.dart';
import '../controllers/cash_register_controller.dart';

class CashRegisterBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<BaseHttpClient>(() => BaseHttpClient());
    Get.lazyPut<OrdersRepository>(
      () => OrdersRepository(Get.find<BaseHttpClient>()),
    );
    Get.lazyPut<CashRegisterController>(
      () => CashRegisterController(
        ordersRepository: Get.find<OrdersRepository>(),
      ),
    );
  }
}
