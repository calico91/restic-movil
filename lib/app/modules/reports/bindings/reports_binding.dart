import 'package:get/get.dart';
import 'package:restic_movil/app/data/http/base_http_client.dart';
import 'package:restic_movil/app/data/repositories/reports_repository.dart';
import 'package:restic_movil/app/modules/reports/controllers/reports_controller.dart';

class ReportsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ReportsRepository>(
      () => ReportsRepository(Get.find<BaseHttpClient>()),
    );
    Get.lazyPut<ReportsController>(
      () => ReportsController(Get.find<ReportsRepository>()),
    );
  }
}
