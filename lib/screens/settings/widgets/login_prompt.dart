import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:qine_corner/core/theme/auth_constants.dart';

class LoginPrompt extends StatelessWidget {
  const LoginPrompt({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.account_circle_outlined,
              size: 48,
              color: AuthConstants.kPrimaryColor,
            ),
            const SizedBox(height: 16),
            const Text(
              'Login to Access More Features',
              style: AuthConstants.titleStyle,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            const Text(
              'Sign in to access all features and personalize your experience.',
              style: AuthConstants.subtitleStyle,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                context.go('/login');
              },
              style: AuthConstants.elevatedButtonStyle(),
              child: const Text('Login / Register'),
            ),
          ],
        ),
      ),
    );
  }
}
