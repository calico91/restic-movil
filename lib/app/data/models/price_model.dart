class PriceModel {
  final String? id;
  final double? amount;
  final String? startDate;
  final bool? active;

  PriceModel({this.id, this.amount, this.startDate, this.active});

  factory PriceModel.fromJson(Map<String, dynamic> json) {
    return PriceModel(
      id: json['id'],
      amount: (json['amount'] as num?)?.toDouble(),
      startDate: json['start_date'],
      active: json['active'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'amount': amount,
      'start_date': startDate,
      'active': active,
    };
  }
}
