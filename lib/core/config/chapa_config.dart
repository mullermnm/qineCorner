class ChapaConfig {
  // Use TEST key during development and LIVE key in production
  static const String publicKey = 'CHAPUBK_TEST-Dh9TR6ARSWBBmXINiOF7dV1QHENEK5pu';
  static const String secretKey = 'CHASECK_TEST-N7ZpOucudceytJakUMxzgFBDknMAwOKn';
  // Base URLs
  static const String testBaseUrl = 'https://api.chapa.co/v1/transaction/initialize';
  static const String liveBaseUrl = 'https://api.chapa.co/v1/transaction/initialize';
  
  // Callback URL (used for web checkout)
  static const String callbackUrl = 'https://qinecorner.com/payment-callback';
  
  // Whether we're in test mode or production
  static const bool isTestMode = true;
  
} 