class OrderComboSelectionModel {
  final String? id;
  final String? comboGroupId;
  final String? comboGroupName;
  final String? comboOptionId;
  final String? selectedProductId;
  final String? selectedProductName;
  final double? additionalPrice;
  final int? quantity;

  OrderComboSelectionModel({
    this.id,
    this.comboGroupId,
    this.comboGroupName,
    this.comboOptionId,
    this.selectedProductId,
    this.selectedProductName,
    this.additionalPrice,
    this.quantity,
  });

  factory OrderComboSelectionModel.fromJson(Map<String, dynamic> json) {
    return OrderComboSelectionModel(
      id: json['id'],
      comboGroupId: json['comboGroupId'],
      comboGroupName: json['comboGroupName'],
      comboOptionId: json['comboOptionId'],
      selectedProductId: json['selectedProductId'],
      selectedProductName: json['selectedProductName'],
      additionalPrice: (json['additionalPrice'] as num?)?.toDouble(),
      quantity: json['quantity'] as int?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'comboGroupId': comboGroupId,
      'comboGroupName': comboGroupName,
      'comboOptionId': comboOptionId,
      'selectedProductId': selectedProductId,
      'selectedProductName': selectedProductName,
      'additionalPrice': additionalPrice,
      'quantity': quantity,
    };
  }
}
