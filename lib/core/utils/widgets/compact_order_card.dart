import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:restic_movil/app/data/models/order_model.dart';
import 'package:restic_movil/core/utils/formatters/currency_formatter.dart';
import 'package:restic_movil/core/utils/widgets/order_status_chip.dart';

/*delegado del grid de pedidos: 3 columnas fijas en móviles,
responsive con más columnas en tablets y pantallas grandes*/
SliverGridDelegateWithFixedCrossAxisCount orderGridDelegateFor(
  double maxWidth,
) => SliverGridDelegateWithFixedCrossAxisCount(
  crossAxisCount: maxWidth < 600
      ? 3
      : maxWidth < 1024
      ? 5
      : 6,
  crossAxisSpacing: 12,
  mainAxisSpacing: 12,
  childAspectRatio: 1.0,
);

/*tarjeta compacta de pedido para el modo grilla de pedidos, comandas y caja.
Siempre muestra el número de la orden y adapta su contenido al origen:
- Salón: mesas asignadas
- Para llevar: cliente + hora
- Domicilio: cliente + dirección (fallback teléfono, luego descripción del origen)
*/
class CompactOrderCard extends StatelessWidget {
  final OrderModel order;
  final String? statusLabel;
  final bool showTotal;
  final bool showDate;
  final VoidCallback? onTap;

  const CompactOrderCard({
    super.key,
    required this.order,
    this.statusLabel,
    this.showTotal = false,
    this.showDate = false,
    this.onTap,
  });

  bool get _isTakeAway {
    final code = order.originType?.code;
    final desc = order.originType?.description;
    return code == 'TAKE_AWAY' ||
        code == 'DELIVERY' ||
        desc == 'Para llevar' ||
        desc == 'Domicilio';
  }

  bool get _isDelivery {
    final code = order.originType?.code;
    final desc = order.originType?.description;
    return code == 'DELIVERY' || desc == 'Domicilio';
  }

  /*icono y chevron del origen según su tipo*/
  IconData get _originIcon {
    if (_isDelivery) return Icons.delivery_dining_outlined;
    if (_isTakeAway) return Icons.shopping_bag_outlined;
    return Icons.table_restaurant_outlined;
  }

  /*título principal: mesas (salón) o cliente (domicilio/para llevar)*/
  String get _title {
    if (_isTakeAway) {
      final fullName = order.customer?.fullName ?? '';
      if (fullName.isNotEmpty) return fullName;
      final customerId = order.customer?.id;
      if (customerId != null && customerId.isNotEmpty) return customerId;
      return order.originType?.description ?? 'Sin Información';
    }
    if (order.tables != null && order.tables!.isNotEmpty) {
      return order.tables!.map((t) => t.name).join(', ');
    }
    return order.originType?.description ?? 'Sin Información';
  }

  /*dato secundario según origen: dirección (domicilio), hora (para llevar)*/
  String? get _subtitle {
    if (_isDelivery) {
      final address = order.customer?.address;
      if (address != null && address.isNotEmpty) return address;
      final phone = order.customer?.phone;
      if (phone != null && phone.isNotEmpty) return phone;
      return null;
    }
    if (!_isTakeAway && !_isDelivery) return null;
    final dateText = _formattedTime;
    return dateText.isEmpty ? null : dateText;
  }

  String get _formattedTime {
    if (showDate) {
      final useClosing =
          order.closingDate != null &&
          (order.status == 'Finalizada' || order.status == 'FINALIZED');
      try {
        final date = DateTime.parse(useClosing ? order.closingDate! : order.openingDate!);
        return DateFormat('dd/MM HH:mm').format(date);
      } catch (_) {}
      return '';
    }
    // Para llevar: solo la hora del pedido
    if (order.openingDate != null) {
      try {
        final date = DateTime.parse(order.openingDate!);
        return DateFormat('HH:mm').format(date);
      } catch (_) {}
    }
    return '';
  }

  @override
  Widget build(BuildContext context) {
    final subtitle = _subtitle;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(14),
          child: Padding(
            padding: const EdgeInsets.all(10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        '#${order.orderNumber ?? '—'}',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    OrderStatusChip(
                      status: order.status,
                      label: statusLabel ?? order.status,
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Icon(_originIcon, size: 14, color: Colors.blue[900]),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        _title,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                if (subtitle != null) ...[
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(
                        _subtitleIcon,
                        size: 12,
                        color: Colors.grey[500],
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          subtitle,
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.grey[600],
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],
                if (showDate && _isDelivery)
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Row(
                      children: [
                        Icon(
                          Icons.access_time,
                          size: 12,
                          color: Colors.grey[500],
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            _formattedTime,
                            style: TextStyle(
                              fontSize: 11,
                              color: Colors.grey[600],
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                if (showTotal) ...[
                  const Spacer(),
                  Row(
                    children: [
                      Text(
                        'Total',
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.grey[600],
                        ),
                      ),
                      const Spacer(),
                      Flexible(
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text(
                            CurrencyFormatter.toCurrency(order.total ?? 0),
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Colors.blue[900],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  IconData get _subtitleIcon {
    if (_isDelivery) {
      final address = order.customer?.address;
      final phone = order.customer?.phone;
      if (address != null && address.isNotEmpty) {
        return Icons.location_on_outlined;
      }
      if (phone != null && phone.isNotEmpty) return Icons.phone_outlined;
    }
    return Icons.access_time;
  }
}
