import 'package:qine_corner/core/api/api_config.dart';

class ChapaConfig {
  // Use TEST key during development and LIVE key in production
  static const String publicKey =
      'CHAPUBK_TEST-Dh9TR6ARSWBBmXINiOF7dV1QHENEK5pu';
  static const String secretKey =
      'CHASECK_TEST-N7ZpOucudceytJakUMxzgFBDknMAwOKn';

  // Base URLs
  static const String baseUrl = 'https://api.chapa.co/v1';
  static const String initializeUrl = '$baseUrl/transaction/initialize';
  static const String verifyUrl = '$baseUrl/transaction/verify';

  // Callback URL (used for web checkout)
  static const String callbackUrl = '${ApiConfig.baseUrl}/payment-callback';
  static const String returnUrl = 'qinecorner://payment-return';

  // Whether we're in test mode or production
  static const bool isTestMode = true;

  // Webhook secret for verifying webhook signatures
  static const String webhookSecret = 'your-webhook-secret-here';

  // Subscription plans
  static const Map<String, double> subscriptionPlans = {
    'monthly': 99.0,
    'yearly': 999.0,
  };
}
