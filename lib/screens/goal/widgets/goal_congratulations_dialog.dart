import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class GoalCongratulationsDialog extends StatelessWidget {
  final VoidCallback onContinueReading;
  final VoidCallback onStop;

  const GoalCongratulationsDialog({
    Key? key,
    required this.onContinueReading,
    required this.onStop,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Lottie.asset(
              'assets/animations/congratulations.json',
              width: 200,
              height: 200,
              repeat: false,
            ),
            const SizedBox(height: 24),
            Text(
              'Congratulations! 🎉',
              style: Theme.of(context).textTheme.headlineSmall,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'You\'ve reached your daily reading goal!',
              style: Theme.of(context).textTheme.bodyLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                TextButton(
                  onPressed: onStop,
                  child: const Text('Stop Reading'),
                ),
                ElevatedButton(
                  onPressed: onContinueReading,
                  child: const Text('Continue Reading'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
