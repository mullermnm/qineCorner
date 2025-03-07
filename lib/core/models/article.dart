import 'package:qine_corner/core/models/user.dart';

enum ArticleStatus { draft, published, deleted }

class ArticleMedia {
  final int id;
  final String url;
  final String type;
  final String? thumbnailUrl;

  const ArticleMedia({
    required this.id,
    required this.url,
    required this.type,
    this.thumbnailUrl,
  });

  factory ArticleMedia.fromJson(Map<String, dynamic> json) {
    return ArticleMedia(
      id: json['id'] as int,
      url: json['url'] as String,
      type: json['type'] as String,
      thumbnailUrl: json['thumbnailUrl'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'url': url,
      'type': type,
      if (thumbnailUrl != null) 'thumbnailUrl': thumbnailUrl,
    };
  }

  ArticleMedia copyWith({
    int? id,
    String? url,
    String? type,
    String? thumbnailUrl,
  }) {
    return ArticleMedia(
      id: id ?? this.id,
      url: url ?? this.url,
      type: type ?? this.type,
      thumbnailUrl: thumbnailUrl ?? this.thumbnailUrl,
    );
  }
}

class Article {
  final int id;
  final String title;
  final String content;
  final User author;
  final List<String> tags;
  final List<ArticleMedia> media;
  final ArticleStatus status;
  final int views;
  final int likes;
  final int comments;
  final int shares;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isLiked;

  const Article({
    required this.id,
    required this.title,
    required this.content,
    required this.author,
    required this.tags,
    required this.media,
    required this.status,
    required this.views,
    required this.likes,
    required this.comments,
    required this.shares,
    required this.createdAt,
    required this.updatedAt,
    this.isLiked = false,
  });

  factory Article.fromJson(Map<String, dynamic> json) {
    return Article(
      id: json['id'] as int,
      title: json['title'] as String,
      content: json['content'] as String,
      author: User.fromJson(json['author'] as Map<String, dynamic>),
      tags: List<String>.from(json['tags'] as List),
      media: (json['media'] as List?)
              ?.map((m) => ArticleMedia.fromJson(m as Map<String, dynamic>))
              .toList() ??
          [],
      status: ArticleStatus.values.firstWhere(
        (s) => s.name == (json['status'] as String).toLowerCase(),
        orElse: () => ArticleStatus.draft,
      ),
      views: json['views'] as int? ?? 0,
      likes: json['likes'] as int? ?? 0,
      comments: json['comments'] as int? ?? 0,
      shares: json['shares'] as int? ?? 0,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      isLiked: json['isLiked'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'content': content,
      'author': author.toJson(),
      'tags': tags,
      'media': media.map((m) => m.toJson()).toList(),
      'status': status.name,
      'views': views,
      'likes': likes,
      'comments': comments,
      'shares': shares,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'isLiked': isLiked,
    };
  }

  Article copyWith({
    int? id,
    String? title,
    String? content,
    User? author,
    List<String>? tags,
    List<ArticleMedia>? media,
    ArticleStatus? status,
    int? views,
    int? likes,
    int? comments,
    int? shares,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isLiked,
  }) {
    return Article(
      id: id ?? this.id,
      title: title ?? this.title,
      content: content ?? this.content,
      author: author ?? this.author,
      tags: tags ?? this.tags,
      media: media ?? this.media,
      status: status ?? this.status,
      views: views ?? this.views,
      likes: likes ?? this.likes,
      comments: comments ?? this.comments,
      shares: shares ?? this.shares,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isLiked: isLiked ?? this.isLiked,
    );
  }

  // Utility getters
  bool get isDraft => status == ArticleStatus.draft;
  bool get isPublished => status == ArticleStatus.published;
  bool get isDeleted => status == ArticleStatus.deleted;

  String get readTime {
    final words = content.split(' ').length;
    final minutes = (words / 200).ceil(); // Average reading speed
    return '$minutes min read';
  }

  // Factory for creating new articles
  factory Article.create({
    required String title,
    required String content,
    required User author,
    required List<String> tags,
    List<ArticleMedia> media = const [],
    ArticleStatus status = ArticleStatus.draft,
  }) {
    return Article(
      id: 0, // Will be set by server
      title: title,
      content: content,
      author: author,
      tags: tags,
      media: media,
      status: status,
      views: 0,
      likes: 0,
      comments: 0,
      shares: 0,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      isLiked: false,
    );
  }
}
