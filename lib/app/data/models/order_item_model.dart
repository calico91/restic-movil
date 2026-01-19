import 'package:restic_movil/app/data/models/product_model.dart';

class OrderItemModel {
  final ProductModel product;
  int quantity;
  String? comment;

  OrderItemModel({
    required this.product,
    this.quantity = 1,
    this.comment,
  });

  double get total => (product.price?.amount ?? 0) * quantity;
}
