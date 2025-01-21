import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class StreakAnimationDialog extends StatefulWidget {
  final int previousStreak;
  final int newStreak;
  final List<String> achievements;
  final VoidCallback onAnimationComplete;

  const StreakAnimationDialog({
    Key? key,
    required this.previousStreak,
    required this.newStreak,
    required this.achievements,
    required this.onAnimationComplete,
  }) : super(key: key);

  @override
  State<StreakAnimationDialog> createState() => _StreakAnimationDialogState();
}

class _StreakAnimationDialogState extends State<StreakAnimationDialog>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  bool _showContinueButton = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );

    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        if (mounted) {
          setState(() {
            _showContinueButton = true;
          });
        }
      }
    });

    // Start animation automatically
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Theme.of(context).dialogBackgroundColor,
          borderRadius: BorderRadius.circular(16),
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                '🎉 Streak Updated! 🎉',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              Lottie.asset(
                'assets/animations/streak.json',
                controller: _controller,
                height: 200,
                repeat: false,
              ),
              const SizedBox(height: 16),
              Text(
                'Your streak increased from ${widget.previousStreak} to ${widget.newStreak} days!',
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 18),
              ),
              if (widget.achievements.isNotEmpty) ...[
                const SizedBox(height: 16),
                Text(
                  'New Achievement: ${widget.achievements.last}',
                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.amber,
                  ),
                ),
              ],
              const SizedBox(height: 24),
              if (_showContinueButton)
                ElevatedButton(
                  onPressed: () {
                    widget.onAnimationComplete();
                  },
                  child: const Text('Continue Reading'),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
