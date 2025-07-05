import 'package:qine_corner/core/api/api_service.dart';
import 'package:qine_corner/core/services/chapa_service.dart';
import 'package:qine_corner/features/subscription/domain/subscription_model.dart';

class SubscriptionService {
  final ApiService _apiService;

  SubscriptionService(this._apiService);

  /// Get the current user's subscription status
  Future<SubscriptionStatus> checkPremiumStatus() async {
    try {
      final response = await _apiService.get('/user/premium-status');
      
      if (response['status'] == 'success') {
        final data = response['data'];
        return SubscriptionStatus.fromJson(data);
      } else {
        throw Exception('Failed to check premium status: ${response['message']}');
      }
    } catch (e) {
      throw Exception('Error checking premium status: $e');
    }
  }

  /// Sync the premium status with the server
  Future<SubscriptionStatus> syncPremiumStatus() async {
    try {
      final response = await _apiService.post(
        '/user/sync-premium', 
        body: {}
      );
      
      if (response['status'] == 'success') {
        final data = response['data'];
        return SubscriptionStatus.fromJson(data);
      } else {
        throw Exception('Failed to sync premium status: ${response['message']}');
      }
    } catch (e) {
      throw Exception('Error syncing premium status: $e');
    }
  }

  /// Verify a payment transaction with the server
  Future<SubscriptionStatus> verifyPayment(String transactionRef) async {
    try {
      // First verify with Chapa directly for security
      final chapaVerification = await _verifyChapaPayment(transactionRef);
      
      if (!chapaVerification['verified']) {
        throw Exception('Payment could not be verified with Chapa: ${chapaVerification['message']}');
      }
      
      // Then update our backend with the verified transaction
      final response = await _apiService.post(
        '/subscriptions/verify',
        body: {
          'transaction_ref': transactionRef,
          'verification_data': chapaVerification['data']
        }
      );
      
      if (response['status'] == 'success') {
        final data = response['data'];
        return SubscriptionStatus.fromJson(data);
      } else {
        throw Exception('Failed to verify payment: ${response['message']}');
      }
    } catch (e) {
      throw Exception('Error verifying payment: $e');
    }
  }
  
  /// Verify payment directly with Chapa API for security
  Future<Map<String, dynamic>> _verifyChapaPayment(String transactionRef) async {
    try {
      // Use the ChapaService to verify the transaction
      final verification = await ChapaService.verifyTransaction(transactionRef);
      
      if (verification['status'] == 'success') {
        return {
          'verified': true,
          'data': verification['data'],
          'message': 'Payment verified successfully'
        };
      } else {
        return {
          'verified': false,
          'data': null,
          'message': verification['message'] ?? 'Unknown verification error'
        };
      }
    } catch (e) {
      return {
        'verified': false,
        'data': null,
        'message': 'Error verifying with Chapa: $e'
      };
    }
  }

  /// Get all subscriptions for the current user
  Future<List<Subscription>> getUserSubscriptions() async {
    try {
      final response = await _apiService.get('/user/subscriptions');
      
      if (response['status'] == 'success') {
        final data = response['data'] as List;
        return data.map((item) => Subscription.fromJson(item)).toList();
      } else {
        throw Exception('Failed to get subscriptions: ${response['message']}');
      }
    } catch (e) {
      throw Exception('Error getting subscriptions: $e');
    }
  }

  /// Initialize a payment with Chapa
  Future<Map<String, dynamic>> initializePayment(double amount, String currency) async {
    try {
      final response = await _apiService.post(
        '/subscriptions/initialize',
        body: {
          'amount': amount,
          'currency': currency,
        }
      );
      
      if (response['status'] == 'success') {
        return response['data'];
      } else {
        throw Exception('Failed to initialize payment: ${response['message']}');
      }
    } catch (e) {
      throw Exception('Error initializing payment: $e');
    }
  }
}
