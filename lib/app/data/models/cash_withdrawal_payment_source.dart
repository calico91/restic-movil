class CashWithdrawalPaymentSource {
  final String name;
  final String description;

  CashWithdrawalPaymentSource({
    required this.name,
    required this.description,
  });

  factory CashWithdrawalPaymentSource.fromJson(Map<String, dynamic> json) {
    return CashWithdrawalPaymentSource(
      name: json['name'],
      description: json['description'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'description': description,
    };
  }

  @override
  String toString() => description;
}
