class PaymentDetailModel {
  double? amount;
  String? paymentMethod;
  String? currency;
  String? cardLastFour;
  String? cardBrand;
  String? authorizationCode;
  String? referenceNumber;
  double? exchangeRate;

  PaymentDetailModel({
    this.amount,
    this.paymentMethod,
    this.currency,
    this.cardLastFour,
    this.cardBrand,
    this.authorizationCode,
    this.referenceNumber,
    this.exchangeRate,
  });

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['amount'] = amount;
    data['paymentMethod'] = paymentMethod;
    data['currency'] = currency;
    data['cardLastFour'] = cardLastFour;
    data['cardBrand'] = cardBrand;
    data['authorizationCode'] = authorizationCode;
    data['referenceNumber'] = referenceNumber;
    data['exchangeRate'] = exchangeRate;
    return data;
  }
}
