import 'package:flutter/material.dart';
import 'package:qine_corner/core/theme/app_colors.dart';
import 'package:qine_corner/common/widgets/primary_button.dart';
import 'package:qine_corner/screens/payment/payment_screen.dart';

class PremiumUpgradeScreen extends StatefulWidget {
  const PremiumUpgradeScreen({super.key});

  @override
  State<PremiumUpgradeScreen> createState() => _PremiumUpgradeScreenState();
}

class _PremiumUpgradeScreenState extends State<PremiumUpgradeScreen> {
  int _selectedPlanIndex = 1; // Default to Pro plan

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Upgrade to Premium'),
        centerTitle: true,
        elevation: 0,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: isDark 
                ? [AppColors.darkBackground, AppColors.darkBackground.withOpacity(0.8)]
                : [Colors.white, Colors.grey.shade50],
          ),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Premium Banner
              _buildPremiumBanner(isDark),
              const SizedBox(height: 30),
              
              // Plan Selection
              _buildPlanSelection(isDark),
              const SizedBox(height: 40),
              
              // Plan Details
              _buildPlanFeatures(isDark),
              const SizedBox(height: 40),
              
              // Subscribe Button
              PrimaryButton(
                text: 'Subscribe Now',
                icon: Icons.star,
                onPressed: _handleSubscribe,
              ),
              const SizedBox(height: 12),
              
              // Terms and privacy
              Center(
                child: Text(
                  'By subscribing, you agree to our Terms & Privacy Policy',
                  style: TextStyle(
                    fontSize: 12,
                    color: isDark ? Colors.grey.shade400 : Colors.grey.shade700,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPremiumBanner(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: LinearGradient(
          colors: [
            Theme.of(context).primaryColor,
            Theme.of(context).primaryColor.withOpacity(0.7),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).primaryColor.withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          const Icon(
            Icons.workspace_premium,
            color: Colors.white,
            size: 56,
          ),
          const SizedBox(height: 16),
          const Text(
            'Unlock the Full Experience',
            style: TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            'Choose a plan that works best for your reading journey',
            style: TextStyle(
              color: Colors.white.withOpacity(0.8),
              fontSize: 16,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildPlanSelection(bool isDark) {
    return Row(
      children: [
        Expanded(
          child: _buildPlanCard(
            index: 0,
            title: 'Basic',
            price: 'ETB 100',
            period: 'month',
            isSelected: _selectedPlanIndex == 0,
            isDark: isDark,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildPlanCard(
            index: 1,
            title: 'Qine Pro',
            price: 'ETB 300',
            period: 'month',
            isSelected: _selectedPlanIndex == 1,
            isDark: isDark,
            isRecommended: true,
          ),
        ),
      ],
    );
  }

  Widget _buildPlanCard({
    required int index,
    required String title,
    required String price,
    required String period,
    required bool isSelected,
    required bool isDark,
    bool isRecommended = false,
  }) {
    return GestureDetector(
      onTap: () => setState(() => _selectedPlanIndex = index),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected
              ? isDark
                  ? Theme.of(context).primaryColor.withOpacity(0.2)
                  : Theme.of(context).primaryColor.withOpacity(0.1)
              : isDark
                  ? AppColors.darkSurfaceBackground
                  : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected
                ? Theme.of(context).primaryColor
                : isDark
                    ? AppColors.darkBackground
                    : Colors.grey.shade300,
            width: 2,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: Theme.of(context).primaryColor.withOpacity(0.2),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ]
              : null,
        ),
        child: Column(
          children: [
            if (isRecommended)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                margin: const EdgeInsets.only(bottom: 8),
                decoration: BoxDecoration(
                  color: Colors.amber[700],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text(
                  'RECOMMENDED',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            Text(
              title,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
                color: isSelected
                    ? Theme.of(context).primaryColor
                    : isDark
                        ? Colors.white
                        : Colors.black87,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  price,
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: isSelected
                        ? Theme.of(context).primaryColor
                        : isDark
                            ? Colors.white
                            : Colors.black,
                  ),
                ),
                const SizedBox(width: 2),
                Text(
                  '/$period',
                  style: TextStyle(
                    fontSize: 14,
                    color: isDark ? Colors.grey.shade400 : Colors.grey.shade700,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isSelected
                    ? Theme.of(context).primaryColor
                    : isDark
                        ? Colors.grey.shade800
                        : Colors.grey.shade200,
                border: Border.all(
                  color: isSelected
                      ? Theme.of(context).primaryColor
                      : isDark
                          ? Colors.grey.shade700
                          : Colors.grey.shade400,
                  width: 2,
                ),
              ),
              child: isSelected
                  ? const Icon(
                      Icons.check,
                      size: 14,
                      color: Colors.white,
                    )
                  : null,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlanFeatures(bool isDark) {
    final basicFeatures = [
      'Ad-Free Experience',
      'No Interruptions',
      'Faster Performance',
    ];

    final proFeatures = [
      ...basicFeatures,
      'Personalized Recommendations',
      'Reading Analytics',
      'Progress Tracker',
      'Unlimited Article Posting',
      'Unlimited Book Clubs Management',
    ];

    final features = _selectedPlanIndex == 0 ? basicFeatures : proFeatures;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurfaceBackground : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _selectedPlanIndex == 0 ? 'Basic Plan Features' : 'Qine Pro Features',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 18,
              color: Theme.of(context).primaryColor,
            ),
          ),
          const SizedBox(height: 16),
          ...features.map((feature) => _buildFeatureItem(feature, isDark)),
        ],
      ),
    );
  }

  Widget _buildFeatureItem(String feature, bool isDark) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.check,
              color: Theme.of(context).primaryColor,
              size: 16,
            ),
          ),
          const SizedBox(width: 12),
          Text(
            feature,
            style: TextStyle(
              fontSize: 16,
              color: isDark ? Colors.white : Colors.black87,
            ),
          ),
        ],
      ),
    );
  }

  void _handleSubscribe() {
    final planName = _selectedPlanIndex == 0 ? 'Basic' : 'Qine Pro';
    final price = _selectedPlanIndex == 0 ? 'ETB 100' : 'ETB 300';
    final period = 'month';  // or 'year' depending on your plans
    
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PaymentScreen(
          planName: planName,
          planPrice: price,
          planPeriod: period,
        ),
      ),
    );
  }
} 