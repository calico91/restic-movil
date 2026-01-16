import 'package:get/get.dart';
import '../controllers/commands_controller.dart';

class CommandsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<CommandsController>(
      () => CommandsController(),
    );
  }
}
