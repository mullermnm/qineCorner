class BookRequest {
  final String? id;
  final String userId;
  final String title;
  final String? authorName;
  final DateTime requestDate;
  final String status; // pending, approved, rejected

  BookRequest({
    this.id,
    required this.userId,
    required this.title,
    this.authorName,
    required this.requestDate,
    required this.status,
  });

  factory BookRequest.fromJson(Map<String, dynamic> json) {
    return BookRequest(
      id: json['id'] as String?,
      userId: json['userId'] as String,
      title: json['title'] as String,
      authorName: json['authorName'] as String?,
      requestDate: DateTime.parse(json['requestDate'] as String),
      status: json['status'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'title': title,
      'authorName': authorName,
      'requestDate': requestDate.toIso8601String(),
      'status': status,
    };
  }
}
