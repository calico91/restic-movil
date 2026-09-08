class SubscriptionModel {
  final String? id;
  final String? ownerId;
  final String? planId;
  final String? planName;
  final String? status;
  final String? billingCycle;
  final DateTime? trialStartedAt;
  final DateTime? trialEndsAt;
  final DateTime? currentPeriodStart;
  final DateTime? currentPeriodEnd;
  final bool? autoRenew;
  final String? suspendedReason;
  final int? lastCalculatedAmount;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final bool? active;

  const SubscriptionModel({
    this.id,
    this.ownerId,
    this.planId,
    this.planName,
    this.status,
    this.billingCycle,
    this.trialStartedAt,
    this.trialEndsAt,
    this.currentPeriodStart,
    this.currentPeriodEnd,
    this.autoRenew,
    this.suspendedReason,
    this.lastCalculatedAmount,
    this.createdAt,
    this.updatedAt,
    this.active,
  });

  factory SubscriptionModel.fromJson(Map<String, dynamic> json) {
    DateTime? parse(Object? v) => v == null ? null : DateTime.parse(v as String);
    return SubscriptionModel(
      id: json['id'] as String?,
      ownerId: json['ownerId'] as String?,
      planId: json['planId'] as String?,
      planName: json['planName'] as String?,
      status: json['status'] as String?,
      billingCycle: json['billingCycle'] as String?,
      trialStartedAt: parse(json['trialStartedAt']),
      trialEndsAt: parse(json['trialEndsAt']),
      currentPeriodStart: parse(json['currentPeriodStart']),
      currentPeriodEnd: parse(json['currentPeriodEnd']),
      autoRenew: json['autoRenew'] as bool?,
      suspendedReason: json['suspendedReason'] as String?,
      lastCalculatedAmount: json['lastCalculatedAmount'] as int?,
      createdAt: parse(json['createdAt']),
      updatedAt: parse(json['updatedAt']),
      active: json['active'] as bool?,
    );
  }
}