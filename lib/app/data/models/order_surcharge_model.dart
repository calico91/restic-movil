class OrderSurchargeModel {
  final String? id;
  final String description;
  final double amount;

  OrderSurchargeModel({
    this.id,
    required this.description,
    required this.amount,
  });

  factory OrderSurchargeModel.fromJson(Map<String, dynamic> json) {
    return OrderSurchargeModel(
      id: json['id'],
      description: json['description'] ?? '',
      amount: (json['amount'] as num?)?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {
      'description': description,
      'amount': amount,
    };
    if (id != null) {
      data['id'] = id;
    }
    return data;
  }
}
