import 'dart:convert';
import 'dart:math';
import 'package:go_router/go_router.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:qine_corner/core/config/chapa_config.dart';
import 'package:webview_flutter/webview_flutter.dart';

class ChapaService {
  // Use the baseUrl from ChapaConfig for consistency
  static String get baseUrl => ChapaConfig.baseUrl;
  
  // Initialize a payment transaction
  static Future<Map<String, dynamic>> initializeTransaction({
    required String amount,
    String? email,
    String? firstName,
    String? lastName,
    required String phone,
    String? txRef,
    String? callbackUrl,
    String? returnUrl,
    String currency = 'ETB',
    String? title,
    String? description,
  }) async {
    try {
      final url = Uri.parse(ChapaConfig.initializeUrl);
      
      print('DEBUG: Preparing Chapa payment');
      
      final Map<String, dynamic> requestBody = {
        'amount': amount,
        'currency': currency,
        'phone_number': phone,
        'tx_ref': txRef ?? _generateTxRef(),
        'callback_url': callbackUrl ?? 'https://qinecorner.com/payment-callback',
        'return_url': returnUrl ?? callbackUrl ?? 'https://qinecorner.com/payment-callback',
      };
      
      if (email != null && email.isNotEmpty) {
        requestBody['email'] = email;
      }
      
      // Only add optional fields if they're provided and valid
      if (firstName != null && firstName.isNotEmpty) {
        requestBody['first_name'] = firstName;
      }
      
      if (lastName != null && lastName.isNotEmpty) {
        requestBody['last_name'] = lastName;
      }
      
      if (title != null && title.isNotEmpty) {
        requestBody['customization[title]'] = title;
      }
      
      if (description != null && description.isNotEmpty) {
        requestBody['customization[description]'] = description;
      }
      
      print('DEBUG: Chapa request body: $requestBody');
      
      final response = await http.post(
        url,
        headers: {
          'Authorization': 'Bearer ${ChapaConfig.secretKey}',
          'Content-Type': 'application/json',
        },
        body: jsonEncode(requestBody),
      );
      
      print('DEBUG: Chapa API response code: ${response.statusCode}');
      print('DEBUG: Chapa API response body: ${response.body}');
      
      if (response.statusCode == 200 || response.statusCode == 201) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to initialize transaction: ${response.body}');
      }
    } catch (e) {
      print('Chapa Error: $e');
      throw Exception('Payment initialization error: $e');
    }
  }
  
  // Verify a transaction status
  static Future<Map<String, dynamic>> verifyTransaction(String txRef) async {
    try {
      final url = Uri.parse('${ChapaConfig.verifyUrl}/$txRef');
      
      final response = await http.get(
        url,
        headers: {
          'Authorization': 'Bearer ${ChapaConfig.secretKey}',
          'Content-Type': 'application/json',
        },
      );
      
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to verify transaction: ${response.body}');
      }
    } catch (e) {
      throw Exception('Transaction verification error: $e');
    }
  }
  
  // Open payment page in a WebView
  static Future<void> openPaymentPage({
    required BuildContext context,
    required String checkoutUrl,
    required String txRef,
    required Function(bool isSuccess) onComplete,
  }) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ChapaWebView(
          checkoutUrl: checkoutUrl,
          callbackUrl: ChapaConfig.callbackUrl,
          txRef: txRef,
        ),
      ),
    );

    // After the WebView is closed, always verify the transaction status
    try {
      print('DEBUG: Verifying payment status for txRef: $txRef');
      final verifyResponse = await verifyTransaction(txRef);
      print('DEBUG: Verification response: $verifyResponse');
      
      // Check if payment was successful based on verification
      final bool isSuccess = 
          verifyResponse['status'] == 'success' && 
          verifyResponse['data'] != null &&
          verifyResponse['data']['status'] == 'success';
      
      print('DEBUG: Payment verification result: $isSuccess');
      onComplete(isSuccess);
    } catch (e) {
      print('DEBUG: Payment verification error: $e');
      onComplete(false);
    }
  }

  // Helper method to generate a transaction reference
  static String _generateTxRef() {
    final random = Random();
    final randomString = String.fromCharCodes(
      List.generate(10, (_) => random.nextInt(26) + 97),
    );
    return 'qine-${DateTime.now().millisecondsSinceEpoch}-$randomString';
  }
}

// WebView page to handle Chapa checkout
class ChapaWebView extends StatefulWidget {
  final String checkoutUrl;
  final String callbackUrl;
  final String txRef;
  
  const ChapaWebView({
    Key? key,
    required this.checkoutUrl,
    required this.callbackUrl,
    required this.txRef,
  }) : super(key: key);
  
  @override
  _ChapaWebViewState createState() => _ChapaWebViewState();
}

class _ChapaWebViewState extends State<ChapaWebView> {
  late WebViewController controller;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (String url) {
            print('DEBUG: WebView loading URL: $url');
            setState(() {
              isLoading = true;
            });

            // When the callback URL is reached, the payment process is complete.
            // Close the WebView to trigger the verification API call.
            if (url.startsWith(widget.callbackUrl)) {
              print(
                  'DEBUG: Callback URL reached. Closing WebView for verification.');
              Navigator.pop(context);
            }
          },
          onPageFinished: (String url) {
            print('DEBUG: WebView finished loading: $url');
            setState(() {
              isLoading = false;
            });
          },
          onWebResourceError: (WebResourceError error) {
            print('WebView error: ${error.description}');
            // Optionally, you could pop with a failure state here
            // if web loading errors should abort the payment.
          },
        ),
      )
      ..loadRequest(Uri.parse(widget.checkoutUrl));
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Complete Payment'),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.close),
            onPressed: () => Navigator.pop(context, false),
          ),
        ],
      ),
      body: Stack(
        children: [
          WebViewWidget(controller: controller),
          if (isLoading)
            const Center(
              child: CircularProgressIndicator(),
            ),
        ],
      ),
    );
  }
} 