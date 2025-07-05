import 'package:qine_corner/core/api/api_service.dart';
import 'package:qine_corner/features/milestones/domain/milestone_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final milestoneServiceProvider =
    Provider((ref) => MilestoneService(ref.read(apiServiceProvider)));

class MilestoneService {
  final ApiService _apiService;

  MilestoneService(this._apiService);

  Future<void> syncMilestone(Milestone milestone) async {
    try {
      await _apiService.post(
        '/milestones/sync',
        body: milestone.toJson(),
      );
    } catch (e) {
      rethrow;
    }
  }
}
