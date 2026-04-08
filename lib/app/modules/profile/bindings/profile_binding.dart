import 'package:get/get.dart';
import 'package:restic_movil/app/data/http/base_http_client.dart';
import 'package:restic_movil/app/modules/profile/controllers/profile_controller.dart';
import 'package:restic_movil/app/modules/profile/repositories/profile_repository.dart';

class ProfileBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => BaseHttpClient());
    Get.lazyPut(() => ProfileRepository(Get.find<BaseHttpClient>()));
    Get.lazyPut(() => ProfileController(Get.find<ProfileRepository>()));
  }
}
