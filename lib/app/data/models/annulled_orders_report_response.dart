class AnnulledOrdersReportResponse {
  final DateTime? startDateTime;
  final DateTime? endDateTime;
  final DateTime? generatedAt;
  final int? totalOrders;
  final int? totalPaidAnnulled;
  final int? totalPrePaidCancelled;
  final double? totalValue;
  final double? totalTipAmount;
  final List<AnnulledOrderSummary>? items;

  AnnulledOrdersReportResponse({
    this.startDateTime,
    this.endDateTime,
    this.generatedAt,
    this.totalOrders,
    this.totalPaidAnnulled,
    this.totalPrePaidCancelled,
    this.totalValue,
    this.totalTipAmount,
    this.items,
  });

  factory AnnulledOrdersReportResponse.fromJson(Map<String, dynamic> json) {
    return AnnulledOrdersReportResponse(
      startDateTime: _parseDateTime(json['startDateTime']),
      endDateTime: _parseDateTime(json['endDateTime']),
      generatedAt: _parseDateTime(json['generatedAt']),
      totalOrders: _parseInt(json['totalOrders']),
      totalPaidAnnulled: _parseInt(json['totalPaidAnnulled']),
      totalPrePaidCancelled: _parseInt(json['totalPrePaidCancelled']),
      totalValue: (json['totalValue'] as num?)?.toDouble(),
      totalTipAmount: (json['totalTipAmount'] as num?)?.toDouble(),
      items: json['items'] != null
          ? (json['items'] as List)
              .map((i) =>
                  AnnulledOrderSummary.fromJson(i as Map<String, dynamic>))
              .toList()
          : null,
    );
  }
}

class AnnulledOrderSummary {
  final String? cancellationType;
  final String? transactionId;
  final String? transactionNumber;
  final String? orderId;
  final int? orderNumber;
  final String? originType;
  final String? customerName;
  final String? waiterName;
  final String? cancelledByName;
  final String? cancellationReason;
  final DateTime? cancelledAt;
  final double? totalValue;
  final double? tipAmount;
  final double? change;
  final String? shiftNumber;
  final String? cashierName;
  final List<PaymentMethodInfo>? paymentMethods;

  AnnulledOrderSummary({
    this.cancellationType,
    this.transactionId,
    this.transactionNumber,
    this.orderId,
    this.orderNumber,
    this.originType,
    this.customerName,
    this.waiterName,
    this.cancelledByName,
    this.cancellationReason,
    this.cancelledAt,
    this.totalValue,
    this.tipAmount,
    this.change,
    this.shiftNumber,
    this.cashierName,
    this.paymentMethods,
  });

  bool get isPaidSale => cancellationType == 'PAID_SALE';

  factory AnnulledOrderSummary.fromJson(Map<String, dynamic> json) {
    return AnnulledOrderSummary(
      cancellationType: json['cancellationType'],
      transactionId: json['transactionId']?.toString(),
      transactionNumber: json['transactionNumber'],
      orderId: json['orderId']?.toString(),
      orderNumber: _parseInt(json['orderNumber']),
      originType: json['originType'],
      customerName: json['customerName'],
      waiterName: json['waiterName'],
      cancelledByName: json['cancelledByName'],
      cancellationReason: json['cancellationReason'],
      cancelledAt: _parseDateTime(json['cancelledAt']),
      totalValue: (json['totalValue'] as num?)?.toDouble(),
      tipAmount: (json['tipAmount'] as num?)?.toDouble(),
      change: (json['change'] as num?)?.toDouble(),
      shiftNumber: json['shiftNumber'],
      cashierName: json['cashierName'],
      paymentMethods: json['paymentMethods'] != null
          ? (json['paymentMethods'] as List)
              .map((p) =>
                  PaymentMethodInfo.fromJson(p as Map<String, dynamic>))
              .toList()
          : null,
    );
  }
}

class PaymentMethodInfo {
  final String? paymentMethod;
  final double? amount;

  PaymentMethodInfo({this.paymentMethod, this.amount});

  factory PaymentMethodInfo.fromJson(Map<String, dynamic> json) {
    return PaymentMethodInfo(
      paymentMethod: json['paymentMethod'],
      amount: (json['amount'] as num?)?.toDouble(),
    );
  }
}

DateTime? _parseDateTime(dynamic value) {
  if (value == null) return null;
  if (value is String) return DateTime.tryParse(value);
  if (value is List) {
    final parts = value.map((e) => (e as num).toInt()).toList();
    if (parts.length >= 3) {
      final base = DateTime(parts[0], parts[1], parts[2]);
      if (parts.length >= 4) base.add(Duration(hours: parts[3]));
      if (parts.length >= 5) base.add(Duration(minutes: parts[4]));
      if (parts.length >= 6) base.add(Duration(seconds: parts[5]));
      return base;
    }
  }
  return null;
}

int? _parseInt(dynamic value) {
  if (value == null) return null;
  if (value is int) return value;
  if (value is String) return int.tryParse(value);
  return null;
}
