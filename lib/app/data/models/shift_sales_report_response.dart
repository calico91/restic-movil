class ShiftSalesReportResponse {
  final String? shiftId;
  final String? shiftNumber;
  final String? cashierName;
  final String? terminalName;
  final String? shiftStatus;
  final String? openedAt;
  final String? closedAt;
  final String? reportGeneratedAt;
  final int? totalTransactions;
  final double? totalSales;
  final double? totalTips;
  final double? grossRevenue;
  final List<dynamic>? paymentBreakdown;
  final List<dynamic>? cashierSummary;

  ShiftSalesReportResponse({
    this.shiftId,
    this.shiftNumber,
    this.cashierName,
    this.terminalName,
    this.shiftStatus,
    this.openedAt,
    this.closedAt,
    this.reportGeneratedAt,
    this.totalTransactions,
    this.totalSales,
    this.totalTips,
    this.grossRevenue,
    this.paymentBreakdown,
    this.cashierSummary,
  });

  factory ShiftSalesReportResponse.fromJson(Map<String, dynamic> json) {
    return ShiftSalesReportResponse(
      shiftId: json['shiftId'],
      shiftNumber: json['shiftNumber'],
      cashierName: json['cashierName'],
      terminalName: json['terminalName'],
      shiftStatus: json['shiftStatus'],
      openedAt: json['openedAt'],
      closedAt: json['closedAt'],
      reportGeneratedAt: json['reportGeneratedAt'],
      totalTransactions: json['totalTransactions'],
      totalSales: (json['totalSales'] as num?)?.toDouble(),
      totalTips: (json['totalTips'] as num?)?.toDouble(),
      grossRevenue: (json['grossRevenue'] as num?)?.toDouble(),
      paymentBreakdown: json['paymentBreakdown'],
      cashierSummary: json['cashierSummary'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'shiftId': shiftId,
      'shiftNumber': shiftNumber,
      'cashierName': cashierName,
      'terminalName': terminalName,
      'shiftStatus': shiftStatus,
      'openedAt': openedAt,
      'closedAt': closedAt,
      'reportGeneratedAt': reportGeneratedAt,
      'totalTransactions': totalTransactions,
      'totalSales': totalSales,
      'totalTips': totalTips,
      'grossRevenue': grossRevenue,
      'paymentBreakdown': paymentBreakdown,
      'cashierSummary': cashierSummary,
    };
  }
}
