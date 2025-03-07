class Comment {
  final String id;
  final String userId;
  final String articleId;
  final String content;
  final DateTime createdAt;
  final String? parentId;
  final int likes;

  Comment({
    required this.id,
    required this.userId,
    required this.articleId,
    required this.content,
    required this.createdAt,
    this.parentId,
    this.likes = 0,
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
    );
  }
} 