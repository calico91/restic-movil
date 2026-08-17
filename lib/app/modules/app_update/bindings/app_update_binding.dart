import 'package:get/get.dart';

import '../../../data/repositories/app_version_repository.dart';
import '../controllers/app_update_controller.dart';

class AppUpdateBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(
      () => AppVersionRepository(),
      fenix: true,
    );
    Get.lazyPut(
      () => AppUpdateController(
        appVersionRepository: Get.find<AppVersionRepository>(),
      ),
      fenix: true,
    );
  }
}
