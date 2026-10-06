import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:restic_movil/app/data/models/order_model.dart';
import 'package:restic_movil/core/utils/widgets/order_status_chip.dart';

/*acción de una tarjeta compacta de grilla*/
class OrderAction {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color? color;

  const OrderAction({
    required this.icon,
    required this.label,
    required this.onTap,
    this.color,
  });
}

/*hoja de acciones (bottom sheet) que se abre al tocar una tarjeta
compacta en modo grilla: muestra el número de la orden y sus acciones
en forma de lista, replicando las opciones de la tarjeta en modo lista*/
class OrderActionsSheet extends StatelessWidget {
  final OrderModel order;
  final String? statusLabel;
  final List<OrderAction> actions;

  const OrderActionsSheet({
    super.key,
    required this.order,
    required this.actions,
    this.statusLabel,
  });

  /*mostrar la hoja; las acciones se ejecutan tras cerrar la hoja*/
  static void show({
    required OrderModel order,
    required List<OrderAction> actions,
    String? statusLabel,
  }) {
    Get.bottomSheet(
      OrderActionsSheet(order: order, actions: actions, statusLabel: statusLabel),
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      enableDrag: true,
    );
  }

  @override
  Widget build(BuildContext context) {
    final title = order.tables != null && order.tables!.isNotEmpty
        ? order.tables!.map((t) => t.name).join(', ')
        : (order.customer?.fullName.isNotEmpty ?? false)
        ? order.customer!.fullName
        : (order.originType?.description ?? 'Sin Información');

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Pedido #${order.orderNumber ?? '—'}',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          title,
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                  OrderStatusChip(
                    status: order.status,
                    label: statusLabel ?? order.status,
                  ),
                ],
              ),
              const SizedBox(height: 8),
              const Divider(),
              Flexible(
                child: ListView(
                  shrinkWrap: true,
                  padding: EdgeInsets.zero,
                  children: actions
                      .map(
                        (action) => ListTile(
                          leading: Icon(
                            action.icon,
                            color: action.color ?? Colors.blue[900],
                            size: 22,
                          ),
                          title: Text(
                            action.label,
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: action.color ?? Colors.black87,
                            ),
                          ),
                          onTap: () {
                            Get.back();
                            action.onTap();
                          },
                        ),
                      )
                      .toList(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
