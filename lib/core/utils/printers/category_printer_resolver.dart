import 'package:restic_movil/app/data/models/category_model.dart';
import 'package:restic_movil/app/data/models/network_printer_model.dart';
import 'package:restic_movil/app/data/models/order_detail_model.dart';
import 'package:restic_movil/app/data/models/order_item_model.dart';
import 'package:restic_movil/app/data/models/printer_zone_model.dart';

/// ID reservado para la zona "Caja" (impresora principal de red).
const String kCajaZoneId = '__caja__';

/// Agrupa items de una orden por impresora destino usando la configuracion
/// de zonas locales y/o el mapeo categoria->zona.
///
/// Prioridad de resolucion por categoria:
/// 1. Si existe mapeo local [mappings] para [cat.id]:
///    - Si la zona es Caja (id [kCajaZoneId]) => `null` (impresora por defecto).
///    - Si la zona es custom => [NetworkPrinterModel] con la IP/puerto de la zona.
/// 2. Si no hay mapeo local, la categoria cae a `null` (impresora por defecto).
///
/// NUNCA se usa `cat.printerIp` legacy del backend.
///
/// Clave null en el mapa retornado = impresora activa por defecto
/// (Caja si hay red configurada, o el transporte activo en otro caso).
class CategoryPrinterResolver {
  CategoryPrinterResolver._();

  /// Agrupa [OrderItemModel] (nueva orden o adicionales) por impresora destino.
  static Map<NetworkPrinterModel?, List<OrderItemModel>> groupItemsByPrinter(
    List<OrderItemModel> items,
    List<CategoryModel> categories, {
    List<PrinterZoneModel> zones = const [],
    Map<String, String> mappings = const {},
  }) {
    // Construir mapa subcategoryId -> CategoryModel para busqueda eficiente
    final Map<String, CategoryModel> subToCategory = {};
    for (final CategoryModel cat in categories) {
      for (final sub in cat.subcategories ?? []) {
        if (sub.id != null) subToCategory[sub.id!] = cat;
      }
    }

    final Map<NetworkPrinterModel?, List<OrderItemModel>> result = {};

    for (final OrderItemModel item in items) {
      final String? subcategoryId = item.product.subcategoryId;
      final CategoryModel? cat =
          subcategoryId != null ? subToCategory[subcategoryId] : null;
      final NetworkPrinterModel? printer =
          _printerFromCategory(cat, zones, mappings);

      result.putIfAbsent(printer, () => []).add(item);
    }

    return result;
  }

  /// Agrupa [OrderDetailModel] (reprints de ordenes existentes) por impresora
  /// destino. Intenta resolver por categoryId top-level y, si no encuentra,
  /// por subcategoryId.
  static Map<NetworkPrinterModel?, List<OrderDetailModel>> groupDetailsByPrinter(
    List<OrderDetailModel> details,
    List<CategoryModel> categories, {
    List<PrinterZoneModel> zones = const [],
    Map<String, String> mappings = const {},
  }) {
    // Mapa categoryId top-level -> CategoryModel
    final Map<String, CategoryModel> catMap = {
      for (final CategoryModel c in categories)
        if (c.id != null) c.id!: c,
    };

    // Mapa subcategoryId -> CategoryModel padre
    final Map<String, CategoryModel> subToCategory = {};
    for (final CategoryModel cat in categories) {
      for (final sub in cat.subcategories ?? []) {
        if (sub.id != null) subToCategory[sub.id!] = cat;
      }
    }

    final Map<NetworkPrinterModel?, List<OrderDetailModel>> result = {};

    for (final OrderDetailModel detail in details) {
      final CategoryModel? cat = detail.categoryId != null
          ? (catMap[detail.categoryId!] ?? subToCategory[detail.categoryId!])
          : null;
      final NetworkPrinterModel? printer =
          _printerFromCategory(cat, zones, mappings);

      result.putIfAbsent(printer, () => []).add(detail);
    }

    return result;
  }

  /// Resuelve la impresora destino para una categoria.
  static NetworkPrinterModel? _printerFromCategory(
    CategoryModel? category,
    List<PrinterZoneModel> zones,
    Map<String, String> mappings,
  ) {
    // 1) Mapeo local categoria -> zona
    if (category?.id != null) {
      final String? zoneId = mappings[category!.id!];
      if (zoneId != null) {
        return _resolveZone(zoneId, zones);
      }
    }

    // 2) Sin asignacion => impresora por defecto
    return null;
  }

  /// Resuelve un zoneId a un [NetworkPrinterModel].
  /// - Caja (id reservado) o vacio => `null` (impresora por defecto).
  /// - ZoneId custom encontrada => modelo de red.
  /// - ZoneId custom no encontrada => `null` (defensivo).
  static NetworkPrinterModel? _resolveZone(
    String zoneId,
    List<PrinterZoneModel> zones,
  ) {
    if (zoneId == kCajaZoneId) return null;
    final PrinterZoneModel? zone = _findZone(zones, zoneId);
    if (zone != null && (zone.ip ?? '').isNotEmpty) {
      return NetworkPrinterModel(
        name: zone.name ?? '',
        ip: zone.ip!,
        port: zone.port ?? 9100,
      );
    }
    return null;
  }

  static PrinterZoneModel? _findZone(
    List<PrinterZoneModel> zones,
    String zoneId,
  ) {
    for (final PrinterZoneModel z in zones) {
      if (z.id == zoneId) return z;
    }
    return null;
  }
}
