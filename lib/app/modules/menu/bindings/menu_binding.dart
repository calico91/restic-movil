import 'package:get/get.dart';
import 'package:restic_movil/app/data/http/base_http_client.dart';
import 'package:restic_movil/app/data/repositories/categories_repository.dart';
import 'package:restic_movil/app/data/repositories/inventory_repository.dart';
import 'package:restic_movil/app/modules/menu/controllers/menu_controller.dart';

class MenuBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => CategoriesRepository(Get.find<BaseHttpClient>()));
    Get.lazyPut(() => InventoryRepository(Get.find<BaseHttpClient>()), fenix: true);
    Get.lazyPut(() => MenuController(Get.find<CategoriesRepository>(), Get.find<InventoryRepository>()));
  }
}
