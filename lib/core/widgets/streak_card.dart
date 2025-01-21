import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/reading_streak_provider.dart';

class StreakCard extends ConsumerWidget {
  const StreakCard({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final streak = ref.watch(readingStreakProvider);
    
    if (streak == null) return const SizedBox.shrink();

    return Card(
      elevation: 4,
      margin: const EdgeInsets.all(8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Current Streak',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${streak.currentStreak} days',
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                Icon(
                  Icons.local_fire_department,
                  color: streak.currentStreak > 0 
                      ? Colors.orange 
                      : Colors.grey,
                  size: 40,
                ),
              ],
            ),
            const Divider(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildStatItem(
                  'Longest Streak',
                  '${streak.longestStreak} days',
                  Icons.emoji_events,
                  Colors.amber,
                ),
                _buildStatItem(
                  'Today\'s Goal',
                  streak.goalAchievedToday ? 'Completed!' : 'Not yet',
                  Icons.task_alt,
                  streak.goalAchievedToday ? Colors.green : Colors.grey,
                ),
              ],
            ),
            if (streak.achievements.isNotEmpty) ...[
              const Divider(height: 24),
              const Text(
                'Recent Achievements',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: streak.achievements
                    .take(3)
                    .map((achievement) => Chip(
                          label: Text(achievement),
                          backgroundColor: Colors.blue.withOpacity(0.1),
                        ))
                    .toList(),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Row(
      children: [
        Icon(icon, color: color, size: 20),
        const SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: const TextStyle(
                fontSize: 14,
                color: Colors.grey,
              ),
            ),
            Text(
              value,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
