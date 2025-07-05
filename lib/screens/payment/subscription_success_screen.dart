import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lottie/lottie.dart';
import 'package:qine_corner/core/theme/app_colors.dart';
import 'package:qine_corner/common/widgets/primary_button.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qine_corner/core/providers/auth_provider.dart';
import 'package:qine_corner/core/api/api_service.dart';
import 'package:qine_corner/screens/error/widgets/animated_error_widget.dart';

class SubscriptionSuccessScreen extends ConsumerStatefulWidget {
  final String planName;
  final String planPeriod;
  final String txRef;
  final DateTime? expiryDate;

  const SubscriptionSuccessScreen({
    Key? key,
    required this.planName,
    required this.planPeriod,
    required this.txRef,
    this.expiryDate,
  }) : super(key: key);

  @override
  ConsumerState<SubscriptionSuccessScreen> createState() => _SubscriptionSuccessScreenState();
}

class _SubscriptionSuccessScreenState extends ConsumerState<SubscriptionSuccessScreen> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  bool _isUpdatingStatus = true;
  bool _updateSuccess = false;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
    
    // Call API to update user status
    _updateUserToPremium();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _updateUserToPremium() async {
    final apiService = ref.read(apiServiceProvider);
    final authState = ref.read(authNotifierProvider).valueOrNull;
    
    if (authState == null || authState.token.isEmpty) {
      setState(() {
        _isUpdatingStatus = false;
        _updateSuccess = false;
        _errorMessage = 'Authentication error. Please login and try again.';
      });
      return;
    }
    
    try {
      // Make API call to upgrade user status
      final response = await apiService.post(
        '/subscriptions/activate',
        body: {
          'plan_name': widget.planName,
          'plan_period': widget.planPeriod,
          'transaction_reference': widget.txRef,
          'user_id': authState.userId,
        },
      );
      
      if (response['success'] == true) {
        // Refresh user data to get updated premium status
        await ref.read(authNotifierProvider.notifier).fetchUser();
        
        setState(() {
          _isUpdatingStatus = false;
          _updateSuccess = true;
        });
      } else {
        setState(() {
          _isUpdatingStatus = false;
          _updateSuccess = false;
          _errorMessage = response['message'] ?? 'Failed to activate subscription';
        });
      }
    } catch (e) {
      print('Error updating subscription status: $e');
      setState(() {
        _isUpdatingStatus = false;
        _updateSuccess = false;
        _errorMessage = 'Error activating subscription. Please contact support.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textTheme = Theme.of(context).textTheme;
    
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: isDark
                ? [AppColors.darkBackground, Color(0xFF0D2D3E)]
                : [Color(0xFFF6FDFF), Color(0xFFE0F7FA)],
          ),
        ),
        child: SafeArea(
          child: _isUpdatingStatus
              ? _buildLoadingView()
              : _updateSuccess
                  ? _buildSuccessView(textTheme, isDark)
                  : _buildErrorView(textTheme, isDark),
        ),
      ),
    );
  }

  Widget _buildLoadingView() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Lottie.asset(
            'assets/animations/premium_loading.json',
            width: 200,
            height: 200,
          ),
          const SizedBox(height: 24),
          Text(
            'Activating your premium subscription...',
            style: TextStyle(fontSize: 18),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          const CircularProgressIndicator(),
        ],
      ),
    );
  }

  Widget _buildSuccessView(TextTheme textTheme, bool isDark) {
    return Column(
      children: [
        const SizedBox(height: 40),
        // Header
        Text(
          'Welcome to Premium!',
          style: textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: isDark ? Colors.white : Colors.black87,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          'Your subscription has been activated',
          style: textTheme.titleMedium,
          textAlign: TextAlign.center,
        ),
        
        // Animation
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 24),
            child: Lottie.asset(
              'assets/animations/premium_success.json',
              fit: BoxFit.contain,
            ),
          ),
        ),
        
        // Benefits
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Card(
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            color: isDark ? AppColors.darkSurfaceBackground : Colors.white,
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'You now have access to:',
                    style: textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildBenefitItem(
                    icon: Icons.star,
                    text: 'Premium content and courses',
                  ),
                  _buildBenefitItem(
                    icon: Icons.speed,
                    text: 'Faster downloads and streams',
                  ),
                  _buildBenefitItem(
                    icon: Icons.people,
                    text: 'Priority customer support',
                  ),
                  _buildBenefitItem(
                    icon: Icons.laptop,
                    text: 'Access on all your devices',
                  ),
                ],
              ),
            ),
          ),
        ),
        
        const SizedBox(height: 24),
        
        // Action buttons
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => context.go('/home'),
                  style: OutlinedButton.styleFrom(
                    padding: EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    side: BorderSide(
                      color: Theme.of(context).primaryColor,
                    ),
                  ),
                  child: Text('Go to Home'),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: PrimaryButton(
                  onPressed: () => context.go('/explore'),
                  text: 'Explore Premium',
                  height: 52,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
      ],
    );
  }

  Widget _buildBenefitItem({required IconData icon, required String text}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              color: Theme.of(context).primaryColor,
              size: 20,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              text,
              style: TextStyle(fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorView(TextTheme textTheme, bool isDark) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedErrorWidget(message: _errorMessage, onRetry: () {
              context.go('/settings');
            }),
            const SizedBox(height: 24),
            Text(
              'Subscription Activation Error',
              style: textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: Colors.red,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Text(
              _errorMessage,
              style: textTheme.bodyLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            PrimaryButton(
              onPressed: () => context.go('/settings'),
              text: 'Back to Settings',
              icon: Icons.settings,
            ),
          ],
        ),
      ),
    );
  }
} 