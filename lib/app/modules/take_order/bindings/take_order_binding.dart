import 'package:get/get.dart';
import 'package:restic_movil/app/data/http/base_http_client.dart';
import 'package:restic_movil/app/data/repositories/orders_repository.dart';
import 'package:restic_movil/app/modules/take_order/controllers/take_order_controller.dart';

class TakeOrderBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => BaseHttpClient());
    Get.lazyPut(() => OrdersRepository(Get.find<BaseHttpClient>()));
    Get.lazyPut(() => TakeOrderController(
      ordersRepository: Get.find(),
      storageService: Get.find(),
    ));
  }
}
