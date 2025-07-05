import 'package:chapasdk/chapasdk.dart';
import 'package:flutter/material.dart';
import 'package:qine_corner/core/providers/auth_provider.dart';
import 'package:qine_corner/core/theme/app_colors.dart';
import 'package:qine_corner/common/widgets/primary_button.dart';
import 'package:qine_corner/core/config/chapa_config.dart';
import 'package:go_router/go_router.dart';
import 'dart:math';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qine_corner/core/services/chapa_service.dart';
import 'package:qine_corner/screens/payment/subscription_success_screen.dart';
import 'package:qine_corner/core/providers/premium_provider.dart';
import 'package:qine_corner/features/subscription/providers/subscription_provider.dart';

class PaymentScreen extends ConsumerStatefulWidget {
  final String planName;
  final String planPrice;
  final String planPeriod;

  const PaymentScreen({
    super.key,
    required this.planName,
    required this.planPrice,
    required this.planPeriod,
  });

  @override
  ConsumerState<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends ConsumerState<PaymentScreen> {
  int _selectedPaymentMethod = 1;
  bool _isProcessing = false;

  // Generate a unique transaction reference
  String _generateTxRef() {
    final random = Random();
    final randomString = String.fromCharCodes(
      List.generate(10, (_) => random.nextInt(26) + 97),
    );
    return 'qine-${DateTime.now().millisecondsSinceEpoch}-$randomString';
  }

  // Process payment with Chapa
  void _processPayment() {
    setState(() => _isProcessing = true);

    try {
      print("DEBUG: Starting custom payment process");

      // Extract amount from price
      final amount = widget.planPrice.replaceAll(RegExp(r'[^0-9.]'), '');

      // Generate unique transaction reference
      final txRef = _generateTxRef();

      // Get user info with better email validation
      final authState = ref.read(authNotifierProvider).valueOrNull;

      // Ensure we have a valid, properly formatted email
      String userEmail = (authState?.user?.email ?? '').trim();
      if (userEmail.isEmpty ||
          !RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(userEmail)) {
        userEmail =
            'customer@example.com'; // Standard fallback email that should pass validation
      }

      print("DEBUG: Using email: $userEmail");

      String? userPhone = authState?.user?.phone;
      String firstName = authState?.user?.name?.split(' ').first ?? 'Qine';
      String lastName = authState?.user?.name?.split(' ').last ?? 'User';

      print("DEBUG: Custom payment - initializing transaction");

      // Initialize transaction with Chapa API
      ChapaService.initializeTransaction(
        amount: amount,
        email: userEmail,
        firstName: firstName,
        lastName: lastName,
        phone: userPhone ?? '0911111111',
        txRef: txRef,
        callbackUrl: ChapaConfig.callbackUrl,
        returnUrl: ChapaConfig.returnUrl,
        title: 'Payment for ${widget.planName}',
        description:
            'Subscription payment for ${widget.planName} (${widget.planPeriod})',
      ).then((response) {
        if (response['status'] == 'success') {
          final checkoutUrl = response['data']['checkout_url'];
          print("DEBUG: Opening checkout URL: $checkoutUrl");

          // Open checkout URL in WebView - pass txRef for verification
          ChapaService.openPaymentPage(
            context: context,
            checkoutUrl: checkoutUrl,
            txRef: txRef,
            onComplete: (isSuccess) {
              if (isSuccess) {
                // Payment verified, now update user status and navigate
                _updateUserToPremium(txRef);
              } else {
                // Stop processing and show error
                setState(() => _isProcessing = false);
                _showPaymentErrorDialog(
                    'Payment was not completed or failed verification.');
              }
            },
          );
        } else {
          setState(() => _isProcessing = false);
          _showPaymentErrorDialog('Could not initialize payment');
        }
      }).catchError((error) {
        print("DEBUG: Payment initialization error");
        setState(() => _isProcessing = false);
        _showPaymentErrorDialog(error.toString());
      });
    } catch (e) {
      print("DEBUG: Payment error: $e");
      setState(() => _isProcessing = false);
      _showPaymentErrorDialog("Payment process failed");
    }
  }

  // Add method to update user to premium with enhanced verification
  void _updateUserToPremium(String txRef) async {
    try {
      print("DEBUG: Starting premium status update for txRef: $txRef");

      // Show a processing dialog while verifying
      _showVerificationDialog();

      // Verify payment with our subscription service
      final subscriptionNotifier =
          ref.read(subscriptionNotifierProvider.notifier);
      final status = await subscriptionNotifier.verifyPayment(txRef);

      // Also update the legacy premium provider for backward compatibility
      await ref.read(premiumProvider.notifier).upgradeToPremium();

      // Hide the verification dialog
      if (mounted) Navigator.of(context).pop();

      // Stop the processing indicator
      setState(() => _isProcessing = false);

      // Navigate to the success screen
      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => SubscriptionSuccessScreen(
              planName: widget.planName,
              planPeriod: widget.planPeriod,
              txRef: txRef,
              expiryDate: DateTime.now()
                  .add(Duration(days: int.parse(widget.planPeriod))),
            ),
          ),
        );
      }
    } catch (e) {
      // Log failure status
      debugPrint("DEBUG: Premium status update failed: $e");

      // Hide the verification dialog if showing
      if (mounted) {
        if (Navigator.of(context).canPop()) {
          Navigator.of(context).pop();
        }
      }

      setState(() => _isProcessing = false);
      _showPaymentErrorDialog(
          'Failed to update your subscription: ${e.toString()}. Please contact support.');
    }
  }

  // Show verification dialog
  void _showVerificationDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Verifying Payment'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: const [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Please wait while we verify your payment...'),
          ],
        ),
      ),
    );
  }

  void _showPaymentErrorDialog(String errorMessage) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Payment Failed'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.error_outline,
              color: Colors.red,
              size: 48,
            ),
            const SizedBox(height: 16),
            Text(
              'There was an issue processing your payment',
              textAlign: TextAlign.center,
            ),
            if (errorMessage.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                errorMessage,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() => _isProcessing = false);
            },
            child: const Text('Try Again'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Payment'),
        centerTitle: true,
        elevation: 0,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: isDark
                ? [
                    AppColors.darkBackground,
                    AppColors.darkBackground.withOpacity(0.8)
                  ]
                : [Colors.white, Colors.grey.shade50],
          ),
        ),
        child: _isProcessing
            ? const Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 20),
                    Text('Processing payment...'),
                  ],
                ),
              )
            : SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Order Summary Card
                    _buildOrderSummary(isDark),
                    const SizedBox(height: 24),

                    // Payment Methods Title
                    Text(
                      'Select Payment Method',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 16),

                    // Payment Method Options
                    _buildPaymentMethods(isDark),
                    const SizedBox(height: 32),

                    // Checkout Button
                    PrimaryButton(
                      onPressed: _processPayment,
                      text: 'Process Payment',
                      isLoading: _isProcessing,
                    ),
                  ],
                ),
              ),
      ),
    );
  }

  Widget _buildOrderSummary(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurfaceBackground : Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Order Summary',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const Divider(height: 24),
          _buildSummaryRow('Plan', widget.planName),
          const SizedBox(height: 8),
          _buildSummaryRow('Period', widget.planPeriod),
          const SizedBox(height: 8),
          _buildSummaryRow('Amount', widget.planPrice, isTotal: true),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value, {bool isTotal = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 16,
            fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 16,
            fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ],
    );
  }

  Widget _buildPaymentMethods(bool isDark) {
    return Column(
      children: [
        _buildPaymentMethod(
          index: 0,
          name: 'Telebirr',
          logoAsset: 'assets/images/telebirr.jpeg',
          isDark: isDark,
        ),
        const SizedBox(height: 12),
        _buildPaymentMethod(
          index: 1,
          name: 'Chapa',
          logoAsset: 'assets/images/chappa.jpeg',
          isDark: isDark,
        ),
      ],
    );
  }

  Widget _buildPaymentMethod({
    required int index,
    required String name,
    required String logoAsset,
    required bool isDark,
  }) {
    final isSelected = _selectedPaymentMethod == index;

    return InkWell(
      onTap: () => setState(() => _selectedPaymentMethod = index),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkSurfaceBackground : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected
                ? Theme.of(context).primaryColor
                : isDark
                    ? Colors.grey.shade800
                    : Colors.grey.shade200,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              padding: const EdgeInsets.all(2),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: Colors.grey.shade200,
                ),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: Image.asset(
                  logoAsset,
                  fit: BoxFit.contain,
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  Text(
                    index == 0
                        ? 'Pay directly with Telebirr'
                        : 'Multiple payment options',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ),
            Radio(
              value: index,
              groupValue: _selectedPaymentMethod,
              onChanged: (value) {
                setState(() => _selectedPaymentMethod = value as int);
              },
              activeColor: Theme.of(context).primaryColor,
            ),
          ],
        ),
      ),
    );
  }
}
