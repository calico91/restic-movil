import 'package:restic_movil/app/data/models/price_model.dart';
import 'package:restic_movil/app/data/models/combo_group_model.dart';

class ProductModel {
  final String? id;
  final String? name;
  final String? description;
  final bool? active;
  final String? subcategoryId;
  final PriceModel? price;
  final String? productType;
  final List<ComboGroupModel>? comboGroups;

  ProductModel({
    this.id,
    this.name,
    this.description,
    this.active,
    this.subcategoryId,
    this.price,
    this.productType,
    this.comboGroups,
  });

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    return ProductModel(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      active: json['active'],
      subcategoryId: json['subcategory_id'],
      price: json['price'] != null ? PriceModel.fromJson(json['price']) : null,
      productType: json['productType'],
      comboGroups: json['combo_groups'] != null
          ? (json['combo_groups'] as List)
                .map((e) => ComboGroupModel.fromJson(e))
                .toList()
          : null,
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
      'productType': productType,
      'combo_groups': comboGroups?.map((e) => e.toJson()).toList(),
    };
  }
}
