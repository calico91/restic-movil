import 'package:restic_movil/app/data/models/recipe_ingredient_model.dart';

class ProductRecipeModel {
  final String? productId;
  final String? priceVariantId;
  final String? priceVariantLabel;
  final List<RecipeIngredientModel>? ingredients;

  ProductRecipeModel({
    this.productId,
    this.priceVariantId,
    this.priceVariantLabel,
    this.ingredients,
  });

  factory ProductRecipeModel.fromJson(Map<String, dynamic> json) {
    return ProductRecipeModel(
      productId: json['productId'],
      priceVariantId: json['priceVariantId'],
      priceVariantLabel: json['priceVariantLabel'],
      ingredients: json['ingredients'] != null
          ? (json['ingredients'] as List)
                .map((e) => RecipeIngredientModel.fromJson(e))
                .toList()
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'productId': productId,
      'priceVariantId': priceVariantId,
      'priceVariantLabel': priceVariantLabel,
      'ingredients': ingredients?.map((e) => e.toJson()).toList(),
    };
  }
}
