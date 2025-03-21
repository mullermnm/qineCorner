import 'package:qine_corner/core/models/user.dart';

class Comment {
  final String id;
  final String userId;
  final String articleId;
  final String content;
  final DateTime createdAt;
  final String? parentId;
  final int likes;
  final bool isLiked;
  final User author;
  final List<Comment> replies;

  Comment({
    required this.id,
    required this.userId,
    required this.articleId,
    required this.content,
    required this.createdAt,
    this.parentId,
    this.likes = 0,
    this.isLiked = false,
    required this.author,
    this.replies = const [],
  });

  factory Comment.fromJson(Map<String, dynamic> json) {
    return Comment(
      id: json['id'].toString(),
      userId: json['user_id'].toString(),
      articleId: json['article_id'].toString(),
      content: json['content'],
      createdAt: DateTime.parse(json['created_at']),
      parentId: json['parent_id']?.toString(),
      likes: json['likes'] ?? 0,
      isLiked: json['is_liked'] ?? false,
      author: User.fromJson(json['author']),
      replies: (json['replies'] as List?)
          ?.map((reply) => Comment.fromJson(reply))
          .toList() ?? [],
    );
  }

  Comment copyWith({
    String? id,
    String? userId,
    String? articleId,
    String? content,
    DateTime? createdAt,
    String? parentId,
    int? likes,
    bool? isLiked,
    User? author,
    List<Comment>? replies,
  }) {
    return Comment(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      articleId: articleId ?? this.articleId,
      content: content ?? this.content,
      createdAt: createdAt ?? this.createdAt,
      parentId: parentId ?? this.parentId,
      likes: likes ?? this.likes,
      isLiked: isLiked ?? this.isLiked,
      author: author ?? this.author,
      replies: replies ?? this.replies,
    );
  }
} 