import 'package:get/get.dart';
import 'package:restic_movil/app/data/repositories/app_version_repository.dart';
import '../controllers/splash_controller.dart';

class SplashBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(
      () => AppVersionRepository(),
      fenix: true,
    );
    Get.put(SplashController(
      appVersionRepository: Get.find<AppVersionRepository>(),
    ));
  }
}
