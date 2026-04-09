import 'package:get/get.dart';
import 'package:restic_movil/app/data/http/base_http_client.dart';
import 'package:restic_movil/app/data/repositories/categories_repository.dart';
import 'package:restic_movil/app/data/repositories/orders_repository.dart';
import '../controllers/orders_controller.dart';

class OrdersBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => BaseHttpClient(), fenix: true);
    Get.lazyPut(
      () => OrdersRepository(Get.find<BaseHttpClient>()),
      fenix: true,
    );
    Get.lazyPut(
      () => CategoriesRepository(Get.find<BaseHttpClient>()),
      fenix: true,
    );
    Get.lazyPut<OrdersController>(
      () => OrdersController(
        ordersRepository: Get.find(),
        categoriesRepository: Get.find(),
      ),
      fenix: true,
    );
  }
}
