import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:qine_corner/features/milestones/data/milestone_repository.dart';
import 'package:qine_corner/features/milestones/domain/milestone_model.dart';

class LocalMilestoneDataSource implements MilestoneRepository {
  static const String _milestonesKey = 'milestones';

  @override
  Future<List<Milestone>> getMilestones() async {
    final prefs = await SharedPreferences.getInstance();
    final List<String>? milestonesJson = prefs.getStringList(_milestonesKey);
    if (milestonesJson == null) {
      return [];
    }
    return milestonesJson
        .map((jsonString) => Milestone.fromJson(json.decode(jsonString)))
        .toList();
  }

  @override
  Future<void> addMilestone(Milestone milestone) async {
    final prefs = await SharedPreferences.getInstance();
    final List<Milestone> currentMilestones = await getMilestones();
    currentMilestones.add(milestone);
    final List<String> updatedMilestonesJson = currentMilestones
        .map((milestone) => json.encode(milestone.toJson()))
        .toList();
    await prefs.setStringList(_milestonesKey, updatedMilestonesJson);
  }

  @override
  Future<void> clearMilestones() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_milestonesKey);
  }

  @override
  Future<void> syncMilestone(Milestone milestone) async {
    // Local data source does not sync to backend, this is handled by the repository implementation.
    // No operation needed here.
  }
}
