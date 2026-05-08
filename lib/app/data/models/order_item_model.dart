import 'package:restic_movil/app/data/models/product_model.dart';
import 'package:restic_movil/app/data/models/price_model.dart';

class OrderItemModel {
  final ProductModel product;
  final PriceModel? selectedPrice;
  int quantity;
  String? comment;
  List<Map<String, String>>? comboSelections;
  double additionalPrice;
  // Para productos COMBINADO: el plato acompañante (el de menor precio)
  final ProductModel? combinedWith;

  OrderItemModel({
    required this.product,
    this.selectedPrice,
    this.quantity = 1,
    this.comment,
    this.comboSelections,
    this.additionalPrice = 0,
    this.combinedWith,
  });

  String get productName => product.productType == 'VARIABLE' && selectedPrice?.sizeLabel != null
      ? '${product.name} - ${selectedPrice!.sizeLabel}'
      : product.name ?? '';

  double get total =>
      ((selectedPrice?.amount ?? (product.prices?.isNotEmpty == true ? product.prices!.first.amount ?? 0 : 0)) + additionalPrice) * quantity;
}
