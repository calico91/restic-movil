import 'package:restic_movil/app/data/models/category_model.dart';
import 'package:restic_movil/app/data/models/network_printer_model.dart';
import 'package:restic_movil/app/data/models/order_detail_model.dart';
import 'package:restic_movil/app/data/models/order_item_model.dart';

/// Agrupa items de una orden por impresora destino usando la configuracion
/// de impresora asignada a cada categoria.
/// Clave null = impresora activa por defecto.
class CategoryPrinterResolver {
  CategoryPrinterResolver._();

  /// Agrupa [OrderItemModel] (nueva orden o adicionales) por impresora destino.
  /// Resuelve la categoria buscando la subcategoria del producto en el arbol de categorias.
  static Map<NetworkPrinterModel?, List<OrderItemModel>> groupItemsByPrinter(
    List<OrderItemModel> items,
    List<CategoryModel> categories,
  ) {
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
      final CategoryModel? cat = subcategoryId != null ? subToCategory[subcategoryId] : null;
      final NetworkPrinterModel? printer = _printerFromCategory(cat);

      result.putIfAbsent(printer, () => []).add(item);
    }

    return result;
  }

  /// Agrupa [OrderDetailModel] (reprints de ordenes existentes) por impresora destino.
  /// Usa el categoryId que viene directamente del backend en cada detalle.
  static Map<NetworkPrinterModel?, List<OrderDetailModel>> groupDetailsByPrinter(
    List<OrderDetailModel> details,
    List<CategoryModel> categories,
  ) {
    // Construir mapa categoryId -> CategoryModel para busqueda eficiente
    final Map<String, CategoryModel> catMap = {
      for (final CategoryModel c in categories)
        if (c.id != null) c.id!: c,
    };

    final Map<NetworkPrinterModel?, List<OrderDetailModel>> result = {};

    for (final OrderDetailModel detail in details) {
      final CategoryModel? cat = detail.categoryId != null ? catMap[detail.categoryId!] : null;
      final NetworkPrinterModel? printer = _printerFromCategory(cat);

      result.putIfAbsent(printer, () => []).add(detail);
    }

    return result;
  }

  /// Retorna un [NetworkPrinterModel] si la categoria tiene IP configurada, o null.
  static NetworkPrinterModel? _printerFromCategory(CategoryModel? category) {
    if (category?.printerIp == null || category!.printerIp!.isEmpty) return null;
    final int port = category.printerPort ?? 9100;
    return NetworkPrinterModel(name: category.name ?? '', ip: category.printerIp!, port: port);
  }
}
