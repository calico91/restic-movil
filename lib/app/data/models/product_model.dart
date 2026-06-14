import 'package:restic_movil/app/data/models/price_model.dart';
import 'package:restic_movil/app/data/models/combo_group_model.dart';

class ProductModel {
  final String? id;
  final String? name;
  final String? description;
  final bool? active;
  final String? subcategoryId;
  final List<PriceModel>? prices;
  final String? productType;
  final List<ComboGroupModel>? comboGroups;
  final bool? requiresRecipe;

  ProductModel({
    this.id,
    this.name,
    this.description,
    this.active,
    this.subcategoryId,
    this.prices,
    this.productType,
    this.comboGroups,
    this.requiresRecipe,
  });

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    return ProductModel(
      id: json['id'] ?? json['_id'],
      name: json['name'],
      description: json['description'],
      active: json['active'],
      subcategoryId: json['subcategory_id'],
      prices: json['prices'] != null
          ? (json['prices'] as List).map((e) => PriceModel.fromJson(e)).toList()
          : null,
      productType: json['productType'],
      comboGroups: json['combo_groups'] != null
          ? (json['combo_groups'] as List)
                .map((e) => ComboGroupModel.fromJson(e))
                .toList()
          : null,
      requiresRecipe: json['requiresRecipe'] ?? json['requires_recipe'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'active': active,
      'subcategory_id': subcategoryId,
      'prices': prices?.map((e) => e.toJson()).toList(),
      'productType': productType,
      'combo_groups': comboGroups?.map((e) => e.toJson()).toList(),
      'requires_recipe': requiresRecipe,
    };
  }
}
