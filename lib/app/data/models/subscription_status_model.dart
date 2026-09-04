class SubscriptionStatusModel {
  final String? subscriptionId;
  final String? status;
  final DateTime? trialEndsAt;
  final DateTime? currentPeriodEnd;
  final String? suspendedReason;

  const SubscriptionStatusModel({
    this.subscriptionId,
    this.status,
    this.trialEndsAt,
    this.currentPeriodEnd,
    this.suspendedReason,
  });

  factory SubscriptionStatusModel.fromJson(Map<String, dynamic> json) {
    return SubscriptionStatusModel(
      subscriptionId: json['subscriptionId'] as String?,
      status: json['status'] as String?,
      trialEndsAt: json['trialEndsAt'] == null
        ? null
        : DateTime.parse(json['trialEndsAt'] as String),
      currentPeriodEnd: json['currentPeriodEnd'] == null
        ? null
        : DateTime.parse(json['currentPeriodEnd'] as String),
      suspendedReason: json['suspendedReason'] as String?,
    );
  }

  bool get isTrial => status == 'TRIAL';
  bool get isActive => status == 'ACTIVE';
  bool get isSuspended => status == 'SUSPENDED';

  int? get trialDaysRemaining {
    if (!isTrial || trialEndsAt == null) return null;
    final now = DateTime.now();
    if (trialEndsAt!.isBefore(now)) return 0;
    return trialEndsAt!.difference(now).inDays;
  }
}