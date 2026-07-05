class PriceModel {
  final String? id;
  final double? amount;
  final String? startDate;
  final bool? active;
  final String? sizeLabel;

  PriceModel({
    this.id,
    this.amount,
    this.startDate,
    this.active,
    this.sizeLabel,
  });

  factory PriceModel.fromJson(Map<String, dynamic> json) {
    return PriceModel(
      id: json['id'] ?? json['_id'],
      amount: (json['amount'] as num?)?.toDouble(),
      startDate: json['start_date'],
      active: json['active'],
      sizeLabel: json['size_label'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'amount': amount,
      'start_date': startDate,
      'active': active,
      if (sizeLabel != null) 'size_label': sizeLabel,
    };
  }
}
