class CashWithdrawal {
  final String id;
  final String shiftId;
  final String shiftNumber;
  final String registeredById;
  final String registeredByName;
  final String reason;
  final String reasonDescription;
  final double amount;
  final String concept;
  final String? voucherReference;
  final String paymentSource;
  final String paymentSourceDescription;
  final String? bankAccountName;
  final String? bankAccountReference;
  final bool alertTriggered;
  final String createdAt;

  CashWithdrawal({
    required this.id,
    required this.shiftId,
    required this.shiftNumber,
    required this.registeredById,
    required this.registeredByName,
    required this.reason,
    required this.reasonDescription,
    required this.amount,
    required this.concept,
    this.voucherReference,
    required this.paymentSource,
    required this.paymentSourceDescription,
    this.bankAccountName,
    this.bankAccountReference,
    required this.alertTriggered,
    required this.createdAt,
  });

  factory CashWithdrawal.fromJson(Map<String, dynamic> json) {
    return CashWithdrawal(
      id: json['id'],
      shiftId: json['shiftId'],
      shiftNumber: json['shiftNumber'],
      registeredById: json['registeredById'],
      registeredByName: json['registeredByName'],
      reason: json['reason'],
      reasonDescription: json['reasonDescription'],
      amount: (json['amount'] as num).toDouble(),
      concept: json['concept'],
      voucherReference: json['voucherReference'],
      paymentSource: json['paymentSource'],
      paymentSourceDescription: json['paymentSourceDescription'],
      bankAccountName: json['bankAccountName'],
      bankAccountReference: json['bankAccountReference'],
      alertTriggered: json['alertTriggered'] ?? false,
      createdAt: json['createdAt'],
    );
  }
}
