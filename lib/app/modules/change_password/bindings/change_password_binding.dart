import 'package:get/get.dart';
import 'package:restic_movil/app/data/http/base_http_client.dart';
import 'package:restic_movil/app/modules/change_password/controllers/change_password_controller.dart';
import 'package:restic_movil/app/modules/profile/repositories/profile_repository.dart';

class ChangePasswordBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ProfileRepository>(
      () => ProfileRepository(BaseHttpClient()),
      fenix: true,
    );
    Get.lazyPut<ChangePasswordController>(() => ChangePasswordController());
  }
}
