import 'package:get/get.dart';
import 'package:restic_movil/app/data/models/order_model.dart';
import 'package:restic_movil/app/data/services/websocket_service.dart';

class CommandsController extends GetxController {
  final WebSocketService _webSocketService = Get.find<WebSocketService>();
  final RxList<OrderModel> orders = <OrderModel>[].obs;

  @override
  void onInit() {
    super.onInit();
    _connectWebSocket();
  }

  void _connectWebSocket() {
    _webSocketService.connect();
    _webSocketService.ordersStream.listen((order) {
      // Agregar el nuevo pedido al inicio de la lista
      orders.insert(0, order);
    });
  }

  @override
  void onClose() {
    _webSocketService.disconnect();
    super.onClose();
  }
}
