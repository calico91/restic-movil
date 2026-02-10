import 'package:restic_movil/app/data/models/product_model.dart';

class OrderItemModel {
  final ProductModel product;
  int quantity;
  String? comment;
  List<Map<String, String>>? comboSelections;
  double additionalPrice;

  OrderItemModel({
    required this.product,
    this.quantity = 1,
    this.comment,
    this.comboSelections,
    this.additionalPrice = 0,
  });

  double get total =>
      ((product.price?.amount ?? 0) + additionalPrice) * quantity;
}
