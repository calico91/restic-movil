import 'package:get/get.dart';
import 'package:restic_movil/app/data/http/base_http_client.dart';
import 'package:restic_movil/app/data/repositories/categories_repository.dart';
import 'package:restic_movil/app/data/repositories/printer_zone_repository.dart';
import '../controllers/printer_settings_controller.dart';

class PrinterSettingsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => BaseHttpClient(), fenix: true);
    Get.lazyPut(() => CategoriesRepository(Get.find<BaseHttpClient>()), fenix: true);
    Get.lazyPut(() => PrinterZoneRepository(Get.find<BaseHttpClient>()), fenix: true);
    Get.put<PrinterSettingsController>(PrinterSettingsController());
  }
}
