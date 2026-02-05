import 'package:get/get.dart';
import 'package:restic_movil/app/data/http/base_http_client.dart';
import 'package:restic_movil/app/data/repositories/categories_repository.dart';
import 'package:restic_movil/app/data/repositories/orders_repository.dart';
import 'package:restic_movil/app/data/repositories/customer_repository.dart';
import 'package:restic_movil/app/data/repositories/tables_repository.dart';
import 'package:restic_movil/app/modules/take_order/controllers/take_order_controller.dart';

class TakeOrderBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => BaseHttpClient());
    Get.lazyPut(() => OrdersRepository(Get.find<BaseHttpClient>()));
    Get.lazyPut(() => TablesRepository(Get.find<BaseHttpClient>()));
    Get.lazyPut(() => CategoriesRepository(Get.find<BaseHttpClient>()));
    Get.lazyPut(() => CustomerRepository(Get.find<BaseHttpClient>()));
    Get.lazyPut(() => TakeOrderController(
      ordersRepository: Get.find(),
      tablesRepository: Get.find(),
      categoriesRepository: Get.find(),
      customerRepository: Get.find(),
      storageService: Get.find(),
    ));
  }
}
