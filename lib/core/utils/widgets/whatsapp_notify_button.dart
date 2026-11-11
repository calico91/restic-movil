import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:restic_movil/app/data/models/order_model.dart';
import 'package:restic_movil/core/utils/snackbars/info_snackbar.dart';
import 'package:restic_movil/core/utils/whatsapp_helper.dart';

/// Chip solido azul que marca un pedido hecho desde la carta web.
class WebOrderBadge extends StatelessWidget {
  const WebOrderBadge({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
      decoration: BoxDecoration(
        color: const Color(0xFF0D47A1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: const Text(
        'WEB',
        style: TextStyle(
          fontSize: 9,
          fontWeight: FontWeight.bold,
          color: Colors.white,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}

/// Boton circular de WhatsApp (verde de marca): abre el chat del cliente con
/// el resumen del pedido recibido. Paso manual del personal; solo para
/// pedidos con telefono (hoy: los hechos por web).
class WhatsappNotifyButton extends StatelessWidget {
  final OrderModel order;
  final double size;

  const WhatsappNotifyButton({super.key, required this.order, this.size = 18});

  Future<void> _notify() async {
    final ok = await openWhatsappForOrder(order);
    if (!ok) {
      Get.showSnackbar(const InfoSnackbar('No se pudo abrir WhatsApp'));
    }
  }

  @override
  Widget build(BuildContext context) {
    return IconButton(
      tooltip: 'Notificar por WhatsApp',
      onPressed: _notify,
      style: IconButton.styleFrom(
        backgroundColor: const Color(0x2625D366),
        shape: const CircleBorder(),
      ),
      constraints: BoxConstraints(minWidth: size, minHeight: size),
      padding: const EdgeInsets.all(4),
      visualDensity: VisualDensity.compact,
      icon: Icon(Icons.chat, size: size, color: const Color(0xFF25D366)),
    );
  }
}

/// Delegado compacto del boton: solo aparece en pedidos web con telefono.
extension WhatsappNotifyFromOrder on OrderModel {
  WhatsappNotifyButton? whatsappButtonIfWeb() {
    final phone = customer?.phone;
    if (originType?.code != 'WEB' || phone == null || phone.isEmpty) {
      return null;
    }
    return WhatsappNotifyButton(order: this);
  }
}
