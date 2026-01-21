class OrderDetailModel {
  final String? id;
  final String? productId;
  final String? productName;
  final double? unitPrice;
  final int? quantity;
  final double? subtotal;
  final String? observations;
  final String? status;
  final String? addedAt;
  final String? preparedAt;
  final String? servedAt;

  OrderDetailModel({
    this.id,
    this.productId,
    this.productName,
    this.unitPrice,
    this.quantity,
    this.subtotal,
    this.observations,
    this.status,
    this.addedAt,
    this.preparedAt,
    this.servedAt,
  });

  factory OrderDetailModel.fromJson(Map<String, dynamic> json) {
    return OrderDetailModel(
      id: json['id'],
      productId: json['productId'],
      productName: json['productName'],
      unitPrice: (json['unitPrice'] as num?)?.toDouble(),
      quantity: json['quantity'],
      subtotal: (json['subtotal'] as num?)?.toDouble(),
      observations: json['observations'],
      status: json['status'],
      addedAt: json['addedAt'],
      preparedAt: json['preparedAt'],
      servedAt: json['servedAt'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'productId': productId,
      'productName': productName,
      'unitPrice': unitPrice,
      'quantity': quantity,
      'subtotal': subtotal,
      'observations': observations,
      'status': status,
      'addedAt': addedAt,
      'preparedAt': preparedAt,
      'servedAt': servedAt,
    };
  }
}
