import 'package:restic_movil/app/data/models/payment_detail_model.dart';

class CreateTransactionRequest {
  String? cashierId;
  List<PaymentDetailModel>? paymentDetails;
  double? tipAmount;
  String? waiterId;
  String? transactionType;
  String? originalTransactionId;
  String? orderId;

  CreateTransactionRequest({
    this.cashierId,
    this.paymentDetails,
    this.tipAmount,
    this.waiterId,
    this.transactionType,
    this.originalTransactionId,
    this.orderId,
  });

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['cashierId'] = cashierId;
    if (paymentDetails != null) {
      data['paymentDetails'] = paymentDetails!.map((v) => v.toJson()).toList();
    }
    data['tipAmount'] = tipAmount;
    data['waiterId'] = waiterId;
    data['transactionType'] = transactionType;
    data['originalTransactionId'] = originalTransactionId;
    data['orderId'] = orderId;
    return data;
  }
}
