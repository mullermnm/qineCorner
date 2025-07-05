// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'subscription_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$SubscriptionImpl _$$SubscriptionImplFromJson(Map<String, dynamic> json) =>
    _$SubscriptionImpl(
      id: json['id'] as String,
      userId: json['userId'] as String,
      transactionRef: json['transactionRef'] as String,
      paymentMethod: json['paymentMethod'] as String,
      amount: (json['amount'] as num).toDouble(),
      currency: json['currency'] as String,
      status: json['status'] as String,
      startDate: DateTime.parse(json['start_date'] as String),
      endDate: DateTime.parse(json['end_date'] as String),
      createdAt: json['created_at'] == null
          ? null
          : DateTime.parse(json['created_at'] as String),
      updatedAt: json['updated_at'] == null
          ? null
          : DateTime.parse(json['updated_at'] as String),
    );

Map<String, dynamic> _$$SubscriptionImplToJson(_$SubscriptionImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'userId': instance.userId,
      'transactionRef': instance.transactionRef,
      'paymentMethod': instance.paymentMethod,
      'amount': instance.amount,
      'currency': instance.currency,
      'status': instance.status,
      'start_date': instance.startDate.toIso8601String(),
      'end_date': instance.endDate.toIso8601String(),
      'created_at': instance.createdAt?.toIso8601String(),
      'updated_at': instance.updatedAt?.toIso8601String(),
    };

_$SubscriptionStatusImpl _$$SubscriptionStatusImplFromJson(
        Map<String, dynamic> json) =>
    _$SubscriptionStatusImpl(
      isPremium: json['isPremium'] as bool,
      expiryDate: json['expiryDate'] == null
          ? null
          : DateTime.parse(json['expiryDate'] as String),
      activeSubscription: json['activeSubscription'] == null
          ? null
          : Subscription.fromJson(
              json['activeSubscription'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$$SubscriptionStatusImplToJson(
        _$SubscriptionStatusImpl instance) =>
    <String, dynamic>{
      'isPremium': instance.isPremium,
      'expiryDate': instance.expiryDate?.toIso8601String(),
      'activeSubscription': instance.activeSubscription,
    };
