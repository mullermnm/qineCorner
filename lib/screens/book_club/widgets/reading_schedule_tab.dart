import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qine_corner/common/widgets/loading_animation.dart';
import 'package:qine_corner/core/providers/reading_schedule_provider.dart';
import 'package:qine_corner/core/theme/app_colors.dart';
import 'package:intl/intl.dart';

class ReadingScheduleTab extends ConsumerWidget {
  final String clubId;

  const ReadingScheduleTab({
    super.key,
    required this.clubId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final schedulesAsync = ref.watch(readingSchedulesProvider(clubId));

    return schedulesAsync.when(
      data: (schedules) {
        if (schedules.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.calendar_today,
                  size: 48,
                  color: AppColors.accentMint.withOpacity(0.5),
                ),
                const SizedBox(height: 16),
                Text(
                  'No reading schedules yet',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: AppColors.accentMint,
                      ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Create a schedule to track reading progress',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context)
                            .textTheme
                            .bodyMedium
                            ?.color
                            ?.withOpacity(0.7),
                      ),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: schedules.length,
          itemBuilder: (context, index) {
            final schedule = schedules[index];
            final isCompleted = DateTime.now().isAfter(schedule.endDate);

            return Card(
              margin: const EdgeInsets.only(bottom: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      isDark ? Colors.grey[850]! : Colors.white,
                      isDark ? Colors.grey[900]! : Colors.grey[50]!,
                    ],
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            isCompleted
                                ? Icons.check_circle
                                : Icons.schedule,
                            color: isCompleted
                                ? Colors.green
                                : Theme.of(context).colorScheme.primary,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            isCompleted ? 'Completed' : 'In Progress',
                            style: TextStyle(
                              color: isCompleted
                                  ? Colors.green
                                  : Theme.of(context).colorScheme.primary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const Spacer(),
                          Text(
                            'Chapters: ${schedule.chapters.join(", ")}',
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: isDark
                                      ? AppColors.darkTextSecondary
                                      : AppColors.lightTextSecondary,
                                ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Icon(
                            Icons.calendar_today,
                            size: 16,
                            color: isDark
                                ? AppColors.darkTextSecondary
                                : AppColors.lightTextSecondary,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '${_formatDate(schedule.startDate)} - ${_formatDate(schedule.endDate)}',
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: isDark
                                      ? AppColors.darkTextSecondary
                                      : AppColors.lightTextSecondary,
                                ),
                          ),
                        ],
                      ),
                      if (schedule.notes != null) ...[
                        const SizedBox(height: 8),
                        Text(schedule.notes!),
                      ],
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
      loading: () => const Center(child: LoadingAnimation()),
      error: (error, stack) => Center(
        child: Text('Error: $error'),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return DateFormat('MMM d, y').format(date);
  }
}
