import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/providers/reading_goal_provider.dart';

class GoalProgressWidget extends ConsumerWidget {
  const GoalProgressWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final goal = ref.watch(readingGoalProvider);

    if (goal == null) return const SizedBox.shrink();

    final progress = goal.todayMinutes / goal.dailyMinutes;
    final isComplete = progress >= 1.0;

    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Today\'s Reading Goal',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                if (isComplete)
                  const Icon(
                    Icons.check_circle,
                    color: Colors.green,
                  ),
              ],
            ),
            const SizedBox(height: 16),
            LinearProgressIndicator(
              value: progress,
              backgroundColor: Theme.of(context).colorScheme.surfaceVariant,
              borderRadius: BorderRadius.circular(8),
              minHeight: 8,
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${goal.todayMinutes} / ${goal.dailyMinutes} minutes',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                if (goal.streakDays > 0)
                  Row(
                    children: [
                      const Icon(Icons.local_fire_department, size: 20),
                      const SizedBox(width: 4),
                      Text(
                        '${goal.streakDays} day streak',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ],
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
