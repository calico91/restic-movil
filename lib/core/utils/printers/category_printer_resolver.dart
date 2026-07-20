import 'package:restic_movil/app/data/models/category_model.dart';
import 'package:restic_movil/app/data/models/network_printer_model.dart';
import 'package:restic_movil/app/data/models/order_detail_model.dart';
import 'package:restic_movil/app/data/models/order_item_model.dart';

class CategoryPrinterResolver {
  CategoryPrinterResolver._();

  /// Agrupa [OrderItemModel] (nueva orden o adicionales) por impresora destino.
  /// La resolucion usa directamente [CategoryModel.printerZone] de cada categoria.
  ///
  /// Prioridad:
  /// 1. Si [cat.printerZone] no es null y tiene IP valida => esa impresora.
  /// 2. Si no => `null` (impresora por defecto / Caja).
  static Map<NetworkPrinterModel?, List<OrderItemModel>> groupItemsByPrinter(
    List<OrderItemModel> items,
    List<CategoryModel> categories,
  ) {
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
      final NetworkPrinterModel? printer = _printerFromCategory(cat);
      result.putIfAbsent(printer, () => []).add(item);
    }

    return result;
  }

  /// Agrupa [OrderDetailModel] (reimpresiones) por impresora destino.
  /// Intenta resolver por categoryId top-level y, si no encuentra,
  /// por subcategoryId.
  static Map<NetworkPrinterModel?, List<OrderDetailModel>> groupDetailsByPrinter(
    List<OrderDetailModel> details,
    List<CategoryModel> categories,
  ) {
    final Map<String, CategoryModel> catMap = {
      for (final CategoryModel c in categories)
        if (c.id != null) c.id!: c,
    };

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
      final NetworkPrinterModel? printer = _printerFromCategory(cat);
      result.putIfAbsent(printer, () => []).add(detail);
    }

    return result;
  }

  /// Resuelve la impresora destino para una categoria.
  /// Null = impresora por defecto (Caja).
  static NetworkPrinterModel? _printerFromCategory(CategoryModel? category) {
    final zone = category?.printerZone;
    if (zone != null && (zone.ip ?? '').isNotEmpty) {
      return NetworkPrinterModel(
        name: zone.name ?? '',
        ip: zone.ip!,
        port: zone.port ?? 9100,
      );
    }
    return null;
  }
}
