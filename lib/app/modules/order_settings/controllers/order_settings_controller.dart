import 'package:get/get.dart';
import 'package:restic_movil/app/modules/home/controllers/home_controller.dart';

class OrderSettingsController extends GetxController {
  final HomeController homeController;

  OrderSettingsController({required this.homeController});

  RxBool get waiterViewOwnOrdersOnly =>
      homeController.waiterViewOwnOrdersOnly;

  bool get canEdit =>
      homeController.userRoles.contains('ADMINISTRADOR') ||
      homeController.userRoles.contains('SUPER');

  Future<void> setWaiterViewOwnOrdersOnly(bool value) =>
      homeController.setWaiterViewOwnOrdersOnly(value);
}
