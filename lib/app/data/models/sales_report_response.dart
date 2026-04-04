class SalesReportResponse {
  final String? startDate;
  final String? endDate;
  final int? totalTransactions;
  final double? totalSales;
  final double? totalTips;
  final double? grossRevenue;
  final List<PaymentBreakdown>? paymentBreakdown;
  final List<CashierSummary>? cashierSummary;

  SalesReportResponse({
    this.startDate,
    this.endDate,
    this.totalTransactions,
    this.totalSales,
    this.totalTips,
    this.grossRevenue,
    this.paymentBreakdown,
    this.cashierSummary,
  });

  factory SalesReportResponse.fromJson(Map<String, dynamic> json) {
    return SalesReportResponse(
      startDate: json['startDate'],
      endDate: json['endDate'],
      totalTransactions: json['totalTransactions'],
      totalSales: (json['totalSales'] as num?)?.toDouble(),
      totalTips: (json['totalTips'] as num?)?.toDouble(),
      grossRevenue: (json['grossRevenue'] as num?)?.toDouble(),
      paymentBreakdown: json['paymentBreakdown'] != null
          ? (json['paymentBreakdown'] as List)
              .map((i) => PaymentBreakdown.fromJson(i))
              .toList()
          : null,
      cashierSummary: json['cashierSummary'] != null
          ? (json['cashierSummary'] as List)
              .map((i) => CashierSummary.fromJson(i))
              .toList()
          : null,
    );
  }
}

class PaymentBreakdown {
  final String? paymentMethod;
  final String? description;
  final double? totalAmount;
  final int? transactionCount;
  final double? percentage;

  PaymentBreakdown({
    this.paymentMethod,
    this.description,
    this.totalAmount,
    this.transactionCount,
    this.percentage,
  });

  factory PaymentBreakdown.fromJson(Map<String, dynamic> json) {
    return PaymentBreakdown(
      paymentMethod: json['paymentMethod'],
      description: json['description'],
      totalAmount: (json['totalAmount'] as num?)?.toDouble(),
      transactionCount: json['transactionCount'],
      percentage: (json['percentage'] as num?)?.toDouble(),
    );
  }
}

class CashierSummary {
  final String? cashierId;
  final String? cashierName;
  final int? transactionCount;
  final double? totalSales;
  final double? totalTips;

  CashierSummary({
    this.cashierId,
    this.cashierName,
    this.transactionCount,
    this.totalSales,
    this.totalTips,
  });

  factory CashierSummary.fromJson(Map<String, dynamic> json) {
    return CashierSummary(
      cashierId: json['cashierId'],
      cashierName: json['cashierName'],
      transactionCount: json['transactionCount'],
      totalSales: (json['totalSales'] as num?)?.toDouble(),
      totalTips: (json['totalTips'] as num?)?.toDouble(),
    );
  }
}