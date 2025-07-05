import 'package:freezed_annotation/freezed_annotation.dart';

part 'subscription_model.freezed.dart';
part 'subscription_model.g.dart';

@freezed
class Subscription with _$Subscription {
  const factory Subscription({
    required String id,
    required String userId,
    required String transactionRef,
    required String paymentMethod,
    required double amount,
    required String currency,
    required String status,
    required DateTime startDate,
    required DateTime endDate,
    required DateTime? createdAt,
    required DateTime? updatedAt,
  }) = _Subscription;

  factory Subscription.fromJson(Map<String, dynamic> json) =>
      _$SubscriptionFromJson(json);
}

@freezed
class SubscriptionStatus with _$SubscriptionStatus {
  const factory SubscriptionStatus({
    required bool isPremium,
    DateTime? expiryDate,
    Subscription? activeSubscription,
  }) = _SubscriptionStatus;

  factory SubscriptionStatus.fromJson(Map<String, dynamic> json) =>
      _$SubscriptionStatusFromJson(json);
}
