import 'package:get/get.dart';
import 'package:restic_movil/app/data/services/websocket_service.dart';
import '../controllers/commands_controller.dart';

class CommandsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<WebSocketService>(() => WebSocketService());
    Get.lazyPut<CommandsController>(
      () => CommandsController(),
    );
  }
}
