import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qine_corner/features/milestones/presentation/providers/milestone_provider.dart';
import 'package:qine_corner/features/milestones/presentation/widgets/milestone_card.dart';

class MyAchievementsScreen extends ConsumerWidget {
  const MyAchievementsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final milestonesAsyncValue = ref.watch(milestoneNotifierProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Achievements'),
        centerTitle: true,
      ),
      body: milestonesAsyncValue.when(
        data: (milestones) {
          if (milestones.isEmpty) {
            return const Center(
              child: Text('No achievements yet. Keep reading!'),
            );
          }
          return ListView.builder(
            itemCount: milestones.length,
            itemBuilder: (context, index) {
              final milestone = milestones[index];
              // Each MilestoneCard needs a unique GlobalKey for RepaintBoundary
              final GlobalKey repaintBoundaryKey = GlobalKey();
              return MilestoneCard(
                milestone: milestone,
                repaintBoundaryKey: repaintBoundaryKey,
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Text('Error loading achievements: ${error.toString()}'),
        ),
      ),
    );
  }
}
