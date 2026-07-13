import 'package:get/get.dart';
import 'package:restic_movil/app/data/http/base_http_client.dart';
import 'package:restic_movil/app/data/repositories/inventory_repository.dart';
import 'package:restic_movil/app/modules/inventory/controllers/inventory_controller.dart';

class InventoryBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => InventoryRepository(Get.find<BaseHttpClient>()), fenix: true);
    Get.lazyPut(() => InventoryController(Get.find<InventoryRepository>()));
  }
}
