import 'package:qine_corner/core/models/user.dart';

class ReadingSchedule {
  final int id;
  final int bookClubId;
  final DateTime startDate;
  final DateTime endDate;
  final List<String> chapters;
  final String? notes;
  final User creator;
  final DateTime createdAt;
  final DateTime updatedAt;

  ReadingSchedule({
    required this.id,
    required this.bookClubId,
    required this.startDate,
    required this.endDate,
    required this.chapters,
    this.notes,
    required this.creator,
    required this.createdAt,
    required this.updatedAt,
  });

  factory ReadingSchedule.fromJson(Map<String, dynamic> json) {
    return ReadingSchedule(
      id: json['id'] as int,
      bookClubId: json['book_club_id'] as int,
      startDate: DateTime.parse(json['start_date'] as String),
      endDate: DateTime.parse(json['end_date'] as String),
      chapters: (json['chapters'] as List).cast<String>(),
      notes: json['notes'] as String,
      creator: User.fromJson(json['creator'] as Map<String, dynamic>),
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'book_club_id': bookClubId,
      'start_date': startDate.toIso8601String(),
      'end_date': endDate.toIso8601String(),
      'chapters': chapters,
      'notes': notes,
      'creator': creator.toJson(),
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}
