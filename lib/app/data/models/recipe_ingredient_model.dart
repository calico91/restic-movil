class RecipeIngredientModel {
  final String? inventoryItemId;
  final String? inventoryItemName;
  final String? unit;
  final double? quantity;

  RecipeIngredientModel({
    this.inventoryItemId,
    this.inventoryItemName,
    this.unit,
    this.quantity,
  });

  factory RecipeIngredientModel.fromJson(Map<String, dynamic> json) {
    return RecipeIngredientModel(
      inventoryItemId: json['inventoryItemId'],
      inventoryItemName: json['inventoryItemName'],
      unit: json['unit'],
      quantity: (json['quantity'] as num?)?.toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'inventoryItemId': inventoryItemId,
      'inventoryItemName': inventoryItemName,
      'unit': unit,
      'quantity': quantity,
    };
  }
}
