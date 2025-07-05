import 'package:qine_corner/features/milestones/domain/milestone_model.dart';

abstract class MilestoneRepository {
  Future<List<Milestone>> getMilestones();
  Future<void> addMilestone(Milestone milestone);
  Future<void> clearMilestones();
  Future<void> syncMilestone(Milestone milestone);
}
