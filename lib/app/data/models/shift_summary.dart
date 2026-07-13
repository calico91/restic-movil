import 'package:restic_movil/app/data/models/payment_method_summary.dart';

class ShiftSummary {
  final String id;
  final String shiftNumber;
  final String cashierId;
  final String cashierName;
  final String terminalId;
  final String terminalCode;
  final String terminalName;
  final double initialAmount;
  final String status;
  final String openedAt;
  final String? closedAt;
  final int totalTransactions;
  final double totalSales;
  final double totalRefunds;
  final double totalTips;
  final double totalWithdrawals;
  final double totalCashWithdrawals;
  final double totalBankWithdrawals;
  final double availableCash;
  final List<PaymentMethodSummary>? paymentSummary;
  final double expectedCashAmount;
  final double? declaredCashAmount;
  final double? difference;
  final String? remarks;

  ShiftSummary({
    required this.id,
    required this.shiftNumber,
    required this.cashierId,
    required this.cashierName,
    required this.terminalId,
    required this.terminalCode,
    required this.terminalName,
    required this.initialAmount,
    required this.status,
    required this.openedAt,
    this.closedAt,
    required this.totalTransactions,
    required this.totalSales,
    required this.totalRefunds,
    required this.totalTips,
    required this.totalWithdrawals,
    required this.totalCashWithdrawals,
    required this.totalBankWithdrawals,
    required this.availableCash,
    this.paymentSummary,
    required this.expectedCashAmount,
    this.declaredCashAmount,
    this.difference,
    this.remarks,
  });

  factory ShiftSummary.fromJson(Map<String, dynamic> json) {
    return ShiftSummary(
      id: json['id'],
      shiftNumber: json['shiftNumber'],
      cashierId: json['cashierId'],
      cashierName: json['cashierName'],
      terminalId: json['terminalId'],
      terminalCode: json['terminalCode'],
      terminalName: json['terminalName'],
      initialAmount: (json['initialAmount'] as num).toDouble(),
      status: json['status'],
      openedAt: json['openedAt'],
      closedAt: json['closedAt'],
      totalTransactions: json['totalTransactions'] ?? 0,
      totalSales: (json['totalSales'] as num?)?.toDouble() ?? 0.0,
      totalRefunds: (json['totalRefunds'] as num?)?.toDouble() ?? 0.0,
      totalTips: (json['totalTips'] as num?)?.toDouble() ?? 0.0,
      totalWithdrawals: (json['totalWithdrawals'] as num?)?.toDouble() ?? 0.0,
      totalCashWithdrawals:
          (json['totalCashWithdrawals'] as num?)?.toDouble() ?? 0.0,
      totalBankWithdrawals:
          (json['totalBankWithdrawals'] as num?)?.toDouble() ?? 0.0,
      availableCash: (json['availableCash'] as num?)?.toDouble() ?? 0.0,
      paymentSummary: json['paymentSummary'] != null
          ? (json['paymentSummary'] as List)
              .map((e) => PaymentMethodSummary.fromJson(e))
              .toList()
          : null,
      expectedCashAmount:
          (json['expectedCashAmount'] as num?)?.toDouble() ?? 0.0,
      declaredCashAmount:
          (json['declaredCashAmount'] as num?)?.toDouble(),
      difference: (json['difference'] as num?)?.toDouble(),
      remarks: json['remarks'],
    );
  }
}
