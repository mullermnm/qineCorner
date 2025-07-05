import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qine_corner/features/milestones/data/local_milestone_data_source.dart';
import 'package:qine_corner/features/milestones/data/milestone_repository.dart';
import 'package:qine_corner/features/milestones/data/milestone_repository_impl.dart';
import 'package:qine_corner/features/milestones/domain/milestone_model.dart';
import 'package:qine_corner/core/services/milestone_service.dart';

final milestoneRepositoryProvider = Provider<MilestoneRepository>(
  (ref) => MilestoneRepositoryImpl(
    LocalMilestoneDataSource(),
    ref.read(milestoneServiceProvider),
  ),
);

final milestoneNotifierProvider = StateNotifierProvider<
    MilestoneNotifier, AsyncValue<List<Milestone>>>((ref) {
  final repository = ref.watch(milestoneRepositoryProvider);
  return MilestoneNotifier(repository);
});

class MilestoneNotifier extends StateNotifier<AsyncValue<List<Milestone>>> {
  final MilestoneRepository _repository;

  MilestoneNotifier(this._repository) : super(const AsyncValue.loading()) {
    _loadMilestones();
  }

  Future<void> _loadMilestones() async {
    try {
      final milestones = await _repository.getMilestones();
      state = AsyncValue.data(milestones);
      // Attempt to sync all loaded milestones to the backend
      for (final milestone in milestones) {
        try {
          await _repository.syncMilestone(milestone);
        } catch (e) {
          print('Failed to sync milestone ${milestone.id} to backend: $e');
        }
      }
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> addMilestone(Milestone milestone) async {
    state = const AsyncValue.loading();
    try {
      await _repository.addMilestone(milestone);
      await _loadMilestones(); // Reload to get the updated list
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> clearMilestones() async {
    state = const AsyncValue.loading();
    try {
      await _repository.clearMilestones();
      state = const AsyncValue.data([]);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}
