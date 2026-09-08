class SubscriptionInvoiceModel {
  final String? id;
  final String? subscriptionId;
  final DateTime? periodStart;
  final DateTime? periodEnd;
  final int? branchCount;
  final int? activeUserCount;
  final int? baseAmount;
  final int? extraBranchAmount;
  final int? extraUserAmount;
  final int? totalAmount;
  final String? status;
  final DateTime? issuedAt;
  final DateTime? dueAt;
  final DateTime? paidAt;
  final String? providerReference;
  final int? proratedDays;
  final int? prorationAmount;
  final String? planName;
  final List<String> branchNames;
  final List<String> activeUserNames;
  final int? extraBranchCount;
  final int? extraUserCount;
  final String? notes;

  const SubscriptionInvoiceModel({
    this.id,
    this.subscriptionId,
    this.periodStart,
    this.periodEnd,
    this.branchCount,
    this.activeUserCount,
    this.baseAmount,
    this.extraBranchAmount,
    this.extraUserAmount,
    this.totalAmount,
    this.status,
    this.issuedAt,
    this.dueAt,
    this.paidAt,
    this.providerReference,
    this.proratedDays,
    this.prorationAmount,
    this.planName,
    this.branchNames = const [],
    this.activeUserNames = const [],
    this.extraBranchCount,
    this.extraUserCount,
    this.notes,
  });

  factory SubscriptionInvoiceModel.fromJson(Map<String, dynamic> json) {
    DateTime? parse(Object? v) => v == null ? null : DateTime.parse(v as String);
    List<String> parseList(Object? v) {
      if (v is List) return v.map((e) => e.toString()).toList();
      return const [];
    }

    return SubscriptionInvoiceModel(
      id: json['id'] as String?,
      subscriptionId: json['subscriptionId'] as String?,
      periodStart: parse(json['periodStart']),
      periodEnd: parse(json['periodEnd']),
      branchCount: json['branchCount'] as int?,
      activeUserCount: json['activeUserCount'] as int?,
      baseAmount: json['baseAmount'] as int?,
      extraBranchAmount: json['extraBranchAmount'] as int?,
      extraUserAmount: json['extraUserAmount'] as int?,
      totalAmount: json['totalAmount'] as int?,
      status: json['status'] as String?,
      issuedAt: parse(json['issuedAt']),
      dueAt: parse(json['dueAt']),
      paidAt: parse(json['paidAt']),
      providerReference: json['providerReference'] as String?,
      proratedDays: json['proratedDays'] as int?,
      prorationAmount: json['prorationAmount'] as int?,
      planName: json['planName'] as String?,
      branchNames: parseList(json['branchNames']),
      activeUserNames: parseList(json['activeUserNames']),
      extraBranchCount: json['extraBranchCount'] as int?,
      extraUserCount: json['extraUserCount'] as int?,
      notes: json['notes'] as String?,
    );
  }

  bool get isProrated => proratedDays != null && proratedDays! > 0;
  bool get isPending => status == 'PENDING';
  bool get isPaid => status == 'PAID';

  bool get hasDetail =>
      planName != null ||
      branchNames.isNotEmpty ||
      activeUserNames.isNotEmpty ||
      extraBranchCount != null ||
      extraUserCount != null;
}