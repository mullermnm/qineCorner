import 'package:qine_corner/features/milestones/data/local_milestone_data_source.dart';
import 'package:qine_corner/features/milestones/data/milestone_repository.dart';
import 'package:qine_corner/features/milestones/domain/milestone_model.dart';
import 'package:qine_corner/core/services/milestone_service.dart';

class MilestoneRepositoryImpl implements MilestoneRepository {
  final LocalMilestoneDataSource _localDataSource;
  final MilestoneService _milestoneService;

  MilestoneRepositoryImpl(this._localDataSource, this._milestoneService);

  @override
  Future<List<Milestone>> getMilestones() {
    return _localDataSource.getMilestones();
  }

  @override
  Future<void> addMilestone(Milestone milestone) async {
    await _localDataSource.addMilestone(milestone);
    // Attempt to sync to backend, but don't block if it fails
    try {
      await _milestoneService.syncMilestone(milestone);
    } catch (e) {
      // Log error or handle it as per app's error handling policy
      print('Failed to sync milestone to backend: $e');
    }
  }

  @override
  Future<void> clearMilestones() {
    return _localDataSource.clearMilestones();
  }

  @override
  Future<void> syncMilestone(Milestone milestone) {
    // This method is primarily for direct sync calls if needed, 
    // but addMilestone already handles the sync attempt.
    return _milestoneService.syncMilestone(milestone);
  }
}
