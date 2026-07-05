class CashierShift {
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
  final double? expectedAmount;
  final double? actualAmount;
  final double? difference;
  final String? remarks;

  CashierShift({
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
    this.expectedAmount,
    this.actualAmount,
    this.difference,
    this.remarks,
  });

  factory CashierShift.fromJson(Map<String, dynamic> json) {
    return CashierShift(
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
      expectedAmount: (json['expectedAmount'] as num?)?.toDouble(),
      actualAmount: (json['actualAmount'] as num?)?.toDouble(),
      difference: (json['difference'] as num?)?.toDouble(),
      remarks: json['remarks'],
    );
  }
}
