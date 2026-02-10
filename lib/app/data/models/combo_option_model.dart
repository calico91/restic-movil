class ComboOptionModel {
  final String? id;
  final String? productId;
  final String? productName;
  final double? additionalPrice;
  final bool? available;
  final int? displayOrder;

  ComboOptionModel({
    this.id,
    this.productId,
    this.productName,
    this.additionalPrice,
    this.available,
    this.displayOrder,
  });

  factory ComboOptionModel.fromJson(Map<String, dynamic> json) {
    return ComboOptionModel(
      id: json['id'],
      productId: json['productId'],
      productName: json['productName'],
      additionalPrice: (json['additionalPrice'] as num?)?.toDouble(),
      available: json['available'],
      displayOrder: json['displayOrder'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'productId': productId,
      'productName': productName,
      'additionalPrice': additionalPrice,
      'available': available,
      'displayOrder': displayOrder,
    };
  }
}
