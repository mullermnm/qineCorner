import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:go_router/go_router.dart';
import 'package:lottie/lottie.dart';
import '../../core/theme/app_colors.dart';
import '../../common/widgets/primary_button.dart';
import '../../common/widgets/secondary_button.dart';
import '../../common/widgets/app_text.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _animationController = PageController();
  final PageController _contentController = PageController();
  int _currentPage = 0;

  final List<OnboardingPage> _pages = [
    OnboardingPage(
      title: 'Welcome to Qine Corner',
      description:
          'Your personal Ethiopian book store, bringing literature to your fingertips.',
      animationPath: 'assets/animations/onboarding_1.json',
    ),
    OnboardingPage(
      title: 'Discover Books',
      description: 'Explore a vast collection of both Amharic and English books.',
      animationPath: 'assets/animations/onboarding_2.json',
    ),
    OnboardingPage(
      title: 'Start Reading',
      description:
          'Find your next favorite book and start your reading journey today.',
      animationPath: 'assets/animations/onboarding_3.json',
    ),
  ];

  void _onNextPage() {
    if (_currentPage == _pages.length - 1) {
      _finishOnboarding();
    } else {
      _animationController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
      _contentController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  Future<void> _finishOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('first_time', false);

    if (!mounted) return;

    if (context.mounted) {
      context.go('/home');
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final size = MediaQuery.of(context).size;

    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            // Skip button
            Positioned(
              top: 16,
              right: 16,
              child: SecondaryButton(
                onPressed: _finishOnboarding,
                text: 'Skip',
                outlined: false,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                height: 40,
                textColor: isDark
                    ? AppColors.darkTextPrimary
                    : AppColors.lightTextPrimary,
              ),
            ),
            // Main content
            Column(
              children: [
                const SizedBox(height: 72), // Space for skip button
                // Animation section (60% of remaining height)
                SizedBox(
                  height: size.height * 0.5, // Adjust this value if needed
                  child: PageView.builder(
                    controller: _animationController,
                    itemCount: _pages.length,
                    onPageChanged: (int page) {
                      setState(() {
                        _currentPage = page;
                      });
                      _contentController.animateToPage(
                        page,
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                      );
                    },
                    itemBuilder: (context, index) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        child: Lottie.asset(
                          _pages[index].animationPath,
                          fit: BoxFit.contain,
                        ),
                      );
                    },
                  ),
                ),
                // Content section
                Expanded(
                  child: PageView.builder(
                    controller: _contentController,
                    itemCount: _pages.length,
                    physics: const NeverScrollableScrollPhysics(),
                    itemBuilder: (context, index) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        child: Column(
                          children: [
                            const SizedBox(height: 24),
                            AppText.h1(
                              _pages[index].title,
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 16),
                            AppText.body(
                              _pages[index].description,
                              textAlign: TextAlign.center,
                              bold: false,
                            ),
                            const Spacer(),
                            // Page indicators
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: List.generate(
                                _pages.length,
                                (index) => Container(
                                  margin: const EdgeInsets.symmetric(horizontal: 4),
                                  width: 8,
                                  height: 8,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: _currentPage == index
                                        ? AppColors.accentMint
                                        : (isDark
                                            ? AppColors.darkTextSecondary
                                            : AppColors.lightTextSecondary),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 24),
                            // Next/Get Started button
                            Padding(
                              padding: const EdgeInsets.only(
                                left: 24,
                                right: 24,
                                bottom: 24,
                              ),
                              child: PrimaryButton(
                                onPressed: _onNextPage,
                                text: _currentPage == _pages.length - 1
                                    ? 'Get Started'
                                    : 'Next',
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    _contentController.dispose();
    super.dispose();
  }
}

class OnboardingPage {
  final String title;
  final String description;
  final String animationPath;

  const OnboardingPage({
    required this.title,
    required this.description,
    required this.animationPath,
  });
}
