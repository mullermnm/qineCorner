import 'package:flutter/material.dart';
import 'package:qine_corner/core/theme/auth_constants.dart';
import 'package:qine_corner/screens/auth/verification_screen.dart';

class VerificationDialog extends StatelessWidget {
  final String userId;
  final String phone;

  const VerificationDialog({
    super.key,
    required this.userId,
    required this.phone,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Phone Verification Required'),
      content: const Text(
        'Please verify your phone number to continue using the app.',
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Later'),
        ),
        ElevatedButton(
          onPressed: () async {
            Navigator.pop(context); // Close dialog
            final result = await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => VerificationScreen(
                  userId: userId,
                  phone: phone,
                ),
              ),
            );
            if (result == true && context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Phone number verified successfully!'),
                ),
              );
            }
          },
          style: AuthConstants.elevatedButtonStyle(),
          child: const Text('Verify Now'),
        ),
      ],
    );
  }

  static Future<void> show({
    required BuildContext context,
    required String userId,
    required String phone,
  }) {
    return showDialog(
      context: context,
      builder: (context) => VerificationDialog(
        userId: userId,
        phone: phone,
      ),
    );
  }
}
