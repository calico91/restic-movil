class AssociatedProductModel {
  final String? productId;
  final String? productName;
  final String? productType;
  final String? priceVariantLabel;
  final double? quantity;

  AssociatedProductModel({
    this.productId,
    this.productName,
    this.productType,
    this.priceVariantLabel,
    this.quantity,
  });

  factory AssociatedProductModel.fromJson(Map<String, dynamic> json) {
    return AssociatedProductModel(
      productId: json['productId'],
      productName: json['productName'],
      productType: json['productType'],
      priceVariantLabel: json['priceVariantLabel'],
      quantity: (json['quantity'] as num?)?.toDouble(),
    );
  }
}
