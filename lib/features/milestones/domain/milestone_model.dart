import 'package:freezed_annotation/freezed_annotation.dart';

part 'milestone_model.freezed.dart';
part 'milestone_model.g.dart';

@freezed
class Milestone with _$Milestone {
  const factory Milestone({
    required String id,
    required String name,
    required String description,
    required DateTime achievedDate,
    required String type,
    String? imageUrl,
    String? userId,
  }) = _Milestone;

  factory Milestone.fromJson(Map<String, dynamic> json) =>
      _$MilestoneFromJson(json);
}
