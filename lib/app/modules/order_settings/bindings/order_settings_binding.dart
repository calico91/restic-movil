import 'package:get/get.dart';
import 'package:restic_movil/app/modules/home/controllers/home_controller.dart';
import '../controllers/order_settings_controller.dart';

class OrderSettingsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<OrderSettingsController>(
      () => OrderSettingsController(homeController: Get.find<HomeController>()),
      fenix: true,
    );
  }
}
