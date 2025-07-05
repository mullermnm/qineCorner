class LeaderboardArticle {
  final int id;
  final String title;
  final String author;
  final int likeCount;
  final int commentCount;
  final String? coverImage;
  final int rank;

  const LeaderboardArticle({
    required this.id,
    required this.title,
    required this.author,
    required this.likeCount,
    required this.commentCount,
    this.coverImage,
    required this.rank,
  });

  factory LeaderboardArticle.fromJson(Map<String, dynamic> json) {
    return LeaderboardArticle(
      id: json['id'] as int,
      title: json['title'] as String,
      author: json['author'] as String,
      likeCount: json['like_count'] as int,
      commentCount: json['comment_count'] as int,
      coverImage: json['cover_image'] as String?,
      rank: json['rank'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'author': author,
      'like_count': likeCount,
      'comment_count': commentCount,
      'cover_image': coverImage,
      'rank': rank,
    };
  }
}
