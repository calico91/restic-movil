import 'package:get/get.dart';
import 'package:restic_movil/app/data/http/base_http_client.dart';
import 'package:restic_movil/app/data/repositories/orders_repository.dart';
import 'package:restic_movil/app/data/services/websocket_service.dart';
import '../controllers/commands_controller.dart';

class CommandsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<WebSocketService>(() => WebSocketService());
    Get.lazyPut(() => BaseHttpClient());
    Get.lazyPut(() => OrdersRepository(Get.find<BaseHttpClient>()));
    Get.lazyPut<CommandsController>(
      () => CommandsController(ordersRepository: Get.find()),
    );
  }
}
