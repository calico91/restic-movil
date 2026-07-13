import 'package:get/get.dart';
import 'package:restic_movil/app/data/http/base_http_client.dart';
import 'package:restic_movil/app/data/repositories/auth_repository.dart';

import '../controllers/login_controller.dart';

class AuthBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => BaseHttpClient(), fenix: true);
    Get.lazyPut(() => AuthRepository(Get.find()), fenix: true);

    Get.lazyPut<LoginController>(
      () => LoginController(
        authRepository: Get.find(),
        storageService: Get.find(),
      ),
      fenix: true,
    );
  }
}
