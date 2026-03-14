import 'package:restic_movil/app/data/models/product_model.dart';

class SubcategoryModel {
  final String? id;
  final String? name;
  final String? description;
  final List<ProductModel>? products;

  SubcategoryModel({this.id, this.name, this.description, this.products});

  factory SubcategoryModel.fromJson(Map<String, dynamic> json) {
    return SubcategoryModel(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      products: json['products'] != null
          ? (json['products'] as List)
                .map((e) => ProductModel.fromJson(e))
                .toList()
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'products': products?.map((e) => e.toJson()).toList(),
    };
  }
}
