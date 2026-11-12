import 'dart:async';

import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:restic_movil/app/data/http/base_http_client.dart';
import 'package:restic_movil/app/data/models/order_model.dart';
import 'package:restic_movil/app/data/repositories/orders_repository.dart';
import 'package:restic_movil/app/data/services/websocket_service.dart';
import 'package:restic_movil/core/utils/snackbars/info_snackbar.dart';

/// Alerta global de pedidos web: contador de pedidos abiertos sin atender
/// (badge en el menu principal) + aviso sonoro cuando llega uno nuevo.
/// Deja de alertar cuando el personal notifica al cliente por WhatsApp.
class WebOrdersAlertService extends GetxService {
  /// Pedidos web abiertos que nadie ha notificado al cliente.
  final unattendedWebCount = 0.obs;

  final OrdersRepository _ordersRepository = OrdersRepository(BaseHttpClient());

  StreamSubscription<OrderModel>? _ordersSub;
  StreamSubscription<List<OrderModel>>? _openOrdersSub;
  bool _subscriptionsAttached = false;

  @override
  void onInit() {
    super.onInit();
    unawaited(refreshCount());
  }

  /// Conecta las alertas al WebSocket (los streams son broadcast: agregar
  /// oyentes no duplica la conexion). Se llama al entrar a Pedidos.
  void ensureSubscriptions() {
    if (_subscriptionsAttached || !Get.isRegistered<WebSocketService>()) {
      return;
    }
    final ws = Get.find<WebSocketService>();
    _ordersSub = ws.ordersStream.listen((order) {
      if (order.originType?.code == 'WEB') {
        _announce(order);
      }
    });
    _openOrdersSub = ws.openOrdersStream.listen(updateFromOrders);
    _subscriptionsAttached = true;
  }

  /// Recalcula el contador a partir de la lista de abiertos ya cargada.
  void updateFromOrders(List<OrderModel> openOrders) {
    unattendedWebCount.value = openOrders
        .where(
          (o) =>
              o.originType?.code == 'WEB' &&
              (o.whatsappNotifiedAt == null || o.whatsappNotifiedAt!.isEmpty),
        )
        .length;
  }

  /// Recarga el contador desde la API (pedido nuevo / marcaje externo).
  Future<void> refreshCount() async {
    try {
      final orders = await _ordersRepository.getOrdersByStatuses(['OPEN']);
      updateFromOrders(orders);
    } catch (_) {
      // El contador se actualizara con el proximo evento o carga de pedidos
    }
  }

  /// El personal notifico al cliente por WhatsApp: deja de alertar el pedido.
  Future<void> markWhatsappNotified(String orderId) async {
    try {
      await _ordersRepository.markWhatsappNotified(orderId);
    } catch (_) {
      // best-effort: si el marcaje falla, el pedido sigue alertando
    }
    await refreshCount();
  }

  /*aviso sonoro + snackbar al llegar un pedido web (puede pasar desapercibido)*/
  void _announce(OrderModel order) {
    SystemSound.play(SystemSoundType.alert);
    Get.showSnackbar(
      InfoSnackbar('Pedido web #${order.orderNumber ?? '—'} recibido'),
    );
    unawaited(refreshCount());
  }

  @override
  void onClose() {
    _ordersSub?.cancel();
    _openOrdersSub?.cancel();
    super.onClose();
  }
}
