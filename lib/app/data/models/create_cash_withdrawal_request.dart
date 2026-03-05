class CreateCashWithdrawalRequest {
  final double amount;
  final String concept;
  final String paymentSource;
  final String reason;
  final String userId;
  final String? voucherReference;
  final String? bankAccountName;
  final String? bankAccountReference;

  CreateCashWithdrawalRequest({
    required this.amount,
    required this.concept,
    required this.paymentSource,
    required this.reason,
    required this.userId,
    this.voucherReference,
    this.bankAccountName,
    this.bankAccountReference,
  });

  Map<String, dynamic> toJson() {
    return {
      'amount': amount,
      'concept': concept,
      'paymentSource': paymentSource,
      'reason': reason,
      'userId': userId,
      'voucherReference': voucherReference,
      'bankAccountName': bankAccountName,
      'bankAccountReference': bankAccountReference,
    };
  }
}
