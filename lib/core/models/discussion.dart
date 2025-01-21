import 'package:qine_corner/core/models/user.dart';

class Discussion {
  final int id;
  final int bookClubId;
  final String title;
  final String content;
  final User creator;
  final DateTime createdAt;
  final DateTime updatedAt;

  Discussion({
    required this.id,
    required this.bookClubId,
    required this.title,
    required this.content,
    required this.creator,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Discussion.fromJson(Map<String, dynamic> json) {
    return Discussion(
      id: json['id'] as int,
      bookClubId: json['book_club_id'] as int,
      title: json['title'] as String,
      content: json['content'] as String,
      creator: User.fromJson(json['creator'] as Map<String, dynamic>),
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'book_club_id': bookClubId,
      'title': title,
      'content': content,
      'creator': creator.toJson(),
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}
