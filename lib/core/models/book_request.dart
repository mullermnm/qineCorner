class BookRequest {
  final String id;
  final String userId;
  final String title;
  final String? author;
  final String status;
  final DateTime createdAt;

  BookRequest({
    required this.id,
    required this.userId,
    required this.title,
    this.author,
    required this.status,
    required this.createdAt,
  });

  factory BookRequest.fromJson(Map<String, dynamic> json) {
    return BookRequest(
      id: json['id'].toString(),
      userId: json['user_id'].toString(),
      title: json['title'],
      author: json['author'],
      status: json['status'] ?? 'pending',
      createdAt: DateTime.parse(json['created_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'title': title,
      'author': author,
      'status': status,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}
