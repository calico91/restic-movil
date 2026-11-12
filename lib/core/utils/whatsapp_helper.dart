import 'package:restic_movil/app/data/models/order_detail_model.dart';
import 'package:restic_movil/app/data/models/order_model.dart';
import 'package:restic_movil/core/utils/formatters/currency_formatter.dart';
import 'package:url_launcher/url_launcher.dart';

/// Codigo de pais por defecto para numeros locales de 10 digitos (Colombia).
const String kDefaultCountryCode = '57';

/// Estados de linea de detalle que no deben aparecer en el mensaje.
const List<String> kCanceledDetailStatuses = ['CANCELED', 'Anulado'];

/// Moneda compacta para el mensaje: $34.000 (sin espacio tras el simbolo).
String _cop(num? value) =>
    CurrencyFormatter.toCurrency(value ?? 0).replaceAll(' ', '');

/// Normaliza el telefono para wa.me: conserva solo digitos; un celular local
/// de 10 digitos recibe el prefijo 57; si ya trae pais o '+', queda igual.
/// Devuelve null cuando no hay numero usable.
String? normalizeWhatsappPhone(String? phone) {
  if (phone == null) return null;
  final digits = phone.replaceAll(RegExp(r'\D'), '');
  if (digits.isEmpty) return null;
  if (digits.length == 10 && !digits.startsWith(kDefaultCountryCode)) {
    return kDefaultCountryCode + digits;
  }
  return digits;
}

/// URL de chat directo con mensaje predefinido; null sin telefono.
Uri? buildWhatsappUrl(String? phone, String message) {
  final normalized = normalizeWhatsappPhone(phone);
  if (normalized == null) return null;
  return Uri.parse(
    'https://wa.me/$normalized?text=${Uri.encodeComponent(message)}',
  );
}

/// Abre WhatsApp en el chat del cliente. false si no hay telefono o el
/// enlace no pudo abrirse.
Future<bool> launchWhatsapp({
  required String? phone,
  required String message,
}) async {
  final uri = buildWhatsappUrl(phone, message);
  if (uri == null) return false;
  return launchUrl(uri, mode: LaunchMode.externalApplication);
}

/// Linea de item del anexo: categoria - producto (tamano) xCant = $linea.
String _detailLine(OrderDetailModel detail) {
  final parts = <String>[];
  if ((detail.categoryName ?? '').trim().isNotEmpty) {
    parts.add(detail.categoryName!.trim());
  }
  final name = (detail.productName ?? '').trim().isEmpty
      ? 'Producto'
      : detail.productName!.trim();
  parts.add(name);
  if ((detail.sizeLabel ?? '').trim().isNotEmpty) {
    parts.add('(${detail.sizeLabel!.trim()})');
  }
  final lineTotal =
      detail.subtotal ?? (detail.unitPrice ?? 0) * (detail.quantity ?? 1);
  return '${parts.join(' - ')} x${detail.quantity ?? 1} = ${_cop(lineTotal)}';
}

/// Direccion de entrega del PROPIO pedido (prefijo "DOMICILIO: ..." del
/// observations, sin las notas del cliente tras el "|"); null en para llevar.
/// Nunca se usa la direccion del perfil del cliente: en pedidos para llevar
/// el perfil conserva la del ultimo domicilio y generaria confusion.
String? _deliveryAddressFromOrder(OrderModel order) {
  final obs = (order.observations ?? '').trim();
  if (!obs.toUpperCase().startsWith('DOMICILIO')) {
    return null;
  }
  final address = obs.substring('DOMICILIO:'.length).split('|').first.trim();
  return address.isEmpty ? null : address;
}

/// Mensaje de confirmacion de recibido para pedidos hechos desde la carta
/// web. Resumen tipo recibo: items visibles (excluye anulados), recargos por
/// nombre (ej: "Domicilio: $5.000"), totales y datos de entrega. Sin emojis:
/// viajan mejor por el enlace compartido de WhatsApp.
String webOrderReceivedMessage(OrderModel order) {
  final name = (order.customer?.name ?? '').trim();
  final phone = (order.customer?.phone ?? '').trim();
  final deliveryAddress = _deliveryAddressFromOrder(order);

  final lines = <String>[];
  lines.add(
    name.isEmpty
        ? 'Tu pedido fue recibido con éxito.'
        : 'Hola $name, tu pedido fue recibido con éxito.',
  );

  final visibleDetails = (order.details ?? [])
      .where(
        (d) => d.status == null || !kCanceledDetailStatuses.contains(d.status),
      )
      .toList();
  if (visibleDetails.isNotEmpty) {
    lines.add('');
    lines.add('*Pedido #${order.orderNumber ?? '—'}*');
    for (final detail in visibleDetails) {
      lines.add('• ${_detailLine(detail)}');
    }
  }

  lines.add('');
  if ((order.subtotal ?? 0) > 0) lines.add('Subtotal: ${_cop(order.subtotal)}');

  final surcharges = (order.surcharges ?? [])
      .where((s) => (s.amount) != 0)
      .toList();
  if (surcharges.isNotEmpty) {
    for (final surcharge in surcharges) {
      lines.add(
        '${surcharge.description.trim().isEmpty ? 'Recargo' : surcharge.description.trim()}: ${_cop(surcharge.amount)}',
      );
    }
  } else if ((order.surchargesTotal ?? 0) > 0) {
    lines.add('Recargos: ${_cop(order.surchargesTotal)}');
  }

  lines.add('*Total a pagar: ${_cop(order.total)}*');

  lines.add('');
  if (name.isNotEmpty || phone.isNotEmpty) lines.add('Confirma tus datos:');
  if (name.isNotEmpty) lines.add('Nombre: $name');
  if (phone.isNotEmpty) lines.add('Teléfono: $phone');
  if (deliveryAddress != null) {
    lines.add('Ubicación: $deliveryAddress');
  } else {
    lines.add('Recogida en tienda');
  }
  lines.addAll(['', '¡Te avisaremos cuando esté listo!']);

  return lines.join('\n');
}

/// Abre WhatsApp con el recibo generado a partir del pedido web.
/// Opcion silenciosa (no-op) si el pedido no tiene telefono.
Future<bool> openWhatsappForOrder(OrderModel order) {
  return launchWhatsapp(
    phone: order.customer?.phone,
    message: webOrderReceivedMessage(order),
  );
}
