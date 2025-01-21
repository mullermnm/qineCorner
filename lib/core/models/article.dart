import 'package:qine_corner/core/models/user.dart';

class Article {
  final String id;
  final String title;
  final String content;
  final String authorId;
  final List<String> tags;
  final int likes;
  final int comments;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Article({
    required this.id,
    required this.title,
    required this.content,
    required this.authorId,
    required this.tags,
    required this.likes,
    required this.comments,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Article.fromJson(Map<String, dynamic> json) {
    return Article(
      id: json['id'] as String,
      title: json['title'] as String,
      content: json['content'] as String,
      authorId: json['authorId'] as String,
      tags: List<String>.from(json['tags'] as List),
      likes: json['likes'] as int,
      comments: json['comments'] as int,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'content': content,
      'authorId': authorId,
      'tags': tags,
      'likes': likes,
      'comments': comments,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  Article copyWith({
    String? id,
    String? title,
    String? content,
    String? authorId,
    List<String>? tags,
    int? likes,
    int? comments,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Article(
      id: id ?? this.id,
      title: title ?? this.title,
      content: content ?? this.content,
      authorId: authorId ?? this.authorId,
      tags: tags ?? this.tags,
      likes: likes ?? this.likes,
      comments: comments ?? this.comments,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
