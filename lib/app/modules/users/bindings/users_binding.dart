import 'package:get/get.dart';
import 'package:restic_movil/app/data/http/base_http_client.dart';
import 'package:restic_movil/app/data/repositories/users_repository.dart';
import '../controllers/users_controller.dart';

class UsersBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => BaseHttpClient());
    Get.lazyPut(() => UsersRepository(Get.find<BaseHttpClient>()));
    Get.lazyPut(() => UsersController(Get.find<UsersRepository>()));
  }
}
