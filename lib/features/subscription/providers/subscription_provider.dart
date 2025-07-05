import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qine_corner/core/api/api_service.dart';
import 'package:qine_corner/features/subscription/domain/subscription_model.dart';
import 'package:qine_corner/features/subscription/services/subscription_service.dart';

final subscriptionServiceProvider = Provider((ref) => SubscriptionService(ref.read(apiServiceProvider)));

/// Provider for the current user's premium status
final premiumStatusProvider = FutureProvider<SubscriptionStatus>((ref) async {
  final subscriptionService = ref.read(subscriptionServiceProvider);
  return await subscriptionService.checkPremiumStatus();
});

/// Provider for the current user's subscriptions
final userSubscriptionsProvider = FutureProvider<List<Subscription>>((ref) async {
  final subscriptionService = ref.read(subscriptionServiceProvider);
  return await subscriptionService.getUserSubscriptions();
});

/// Notifier for managing subscription state and operations
class SubscriptionNotifier extends StateNotifier<AsyncValue<SubscriptionStatus>> {
  final SubscriptionService _subscriptionService;
  
  SubscriptionNotifier(this._subscriptionService) 
      : super(const AsyncValue.loading());
  
  /// Initialize the notifier by loading the current premium status
  Future<void> initialize() async {
    try {
      state = const AsyncValue.loading();
      final status = await _subscriptionService.checkPremiumStatus();
      state = AsyncValue.data(status);
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
    }
  }
  
  /// Sync the premium status with the server
  Future<void> syncPremiumStatus() async {
    try {
      state = const AsyncValue.loading();
      final status = await _subscriptionService.syncPremiumStatus();
      state = AsyncValue.data(status);
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
    }
  }
  
  /// Verify a payment transaction
  Future<void> verifyPayment(String transactionRef) async {
    try {
      state = const AsyncValue.loading();
      final status = await _subscriptionService.verifyPayment(transactionRef);
      state = AsyncValue.data(status);
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
    }
  }
  
  /// Initialize a payment with Chapa
  Future<Map<String, dynamic>> initializePayment(double amount, String currency) async {
    try {
      return await _subscriptionService.initializePayment(amount, currency);
    } catch (e) {
      throw Exception('Failed to initialize payment: $e');
    }
  }
}

/// Provider for the subscription notifier
final subscriptionNotifierProvider = StateNotifierProvider<SubscriptionNotifier, AsyncValue<SubscriptionStatus>>((ref) {
  final subscriptionService = ref.read(subscriptionServiceProvider);
  return SubscriptionNotifier(subscriptionService)..initialize();
});
