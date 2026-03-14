class CashWithdrawalReason {
  final String name;
  final String description;

  CashWithdrawalReason({required this.name, required this.description});

  factory CashWithdrawalReason.fromJson(Map<String, dynamic> json) {
    return CashWithdrawalReason(
      name: json['name'],
      description: json['description'],
    );
  }

  Map<String, dynamic> toJson() {
    return {'name': name, 'description': description};
  }

  @override
  String toString() => description;
}
