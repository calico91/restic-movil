class PaymentMethodSummary {
  final String paymentMethod;
  final String description;
  final double totalCollected;

  PaymentMethodSummary({
    required this.paymentMethod,
    required this.description,
    required this.totalCollected,
  });

  factory PaymentMethodSummary.fromJson(Map<String, dynamic> json) {
    return PaymentMethodSummary(
      paymentMethod: json['paymentMethod'],
      description: json['description'],
      totalCollected: (json['totalCollected'] as num).toDouble(),
    );
  }
}
