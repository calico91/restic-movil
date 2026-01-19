import 'package:restic_movil/app/data/models/price_model.dart';

class ProductModel {
  final String? id;
  final String? name;
  final String? description;
  final bool? active;
  final String? subcategoryId;
  final PriceModel? price;

  ProductModel({
    this.id,
    this.name,
    this.description,
    this.active,
    this.subcategoryId,
    this.price,
  });

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    return ProductModel(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      active: json['active'],
      subcategoryId: json['subcategory_id'],
      price: json['price'] != null ? PriceModel.fromJson(json['price']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'active': active,
      'subcategory_id': subcategoryId,
      'price': price?.toJson(),
    };
  }
}
