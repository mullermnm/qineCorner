import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class AnimatedErrorWidget extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;
  final double size;

  const AnimatedErrorWidget({
    super.key,
    required this.message,
    required this.onRetry,
    this.size = 200,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Error animation
          Lottie.asset(
            'assets/animations/error.json',
            width: size,
            height: size,
            repeat: true,
            reverse: true,
          ),
          const SizedBox(height: 16),
          // Error message
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32.0),
            child: Text(
              message,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Theme.of(context).colorScheme.error,
                  ),
            ),
          ),
          const SizedBox(height: 24),
          // Retry button
          ElevatedButton.icon(
            onPressed: onRetry,
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
              foregroundColor: Theme.of(context).colorScheme.onError,
              padding: const EdgeInsets.symmetric(
                horizontal: 24,
                vertical: 12,
              ),
            ),
            icon: const Icon(Icons.refresh),
            label: const Text('Retry'),
          ),
        ],
      ),
    );
  }
}
