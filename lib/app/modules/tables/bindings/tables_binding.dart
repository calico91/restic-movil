import 'package:get/get.dart';
import 'package:restic_movil/app/data/http/base_http_client.dart';
import 'package:restic_movil/app/data/repositories/tables_repository.dart';
import 'package:restic_movil/app/modules/tables/controllers/tables_controller.dart';

class TablesBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<BaseHttpClient>(() => BaseHttpClient());
    Get.lazyPut<TablesRepository>(() => TablesRepository(Get.find<BaseHttpClient>()));
    Get.lazyPut<TablesController>(() => TablesController(repository: Get.find<TablesRepository>()));
  }
}
