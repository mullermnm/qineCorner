class Book {
  final String id;
  final String title;
  final String author;
  final String description;
  final String coverUrl;
  final double rating;
  final List<String> categories; // List of category IDs
  final DateTime publishedAt;
  final String filePath; // Path to the PDF file

  const Book({
    required this.id,
    required this.title,
    required this.author,
    required this.description,
    required this.coverUrl,
    required this.rating,
    required this.categories,
    required this.publishedAt,
    required this.filePath,
  });

  // Add fromJson constructor for future API integration
  factory Book.fromJson(Map<String, dynamic> json) {
    return Book(
      id: json['id'] as String,
      title: json['title'] as String,
      author: json['author'] as String,
      description: json['description'] as String,
      coverUrl: json['coverUrl'] as String,
      rating: (json['rating'] as num).toDouble(),
      categories: List<String>.from(json['categories'] as List),
      publishedAt: DateTime.parse(json['publishedAt'] as String),
      filePath: json['filePath'] as String,
    );
  }

  // Add toJson method for future API integration
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'author': author,
      'description': description,
      'coverUrl': coverUrl,
      'rating': rating,
      'categories': categories,
      'publishedAt': publishedAt.toIso8601String(),
      'filePath': filePath,
    };
  }

  // Add copyWith method for immutable updates
  Book copyWith({
    String? id,
    String? title,
    String? author,
    String? description,
    String? coverUrl,
    double? rating,
    List<String>? categories,
    DateTime? publishedAt,
    String? filePath,
  }) {
    return Book(
      id: id ?? this.id,
      title: title ?? this.title,
      author: author ?? this.author,
      description: description ?? this.description,
      coverUrl: coverUrl ?? this.coverUrl,
      rating: rating ?? this.rating,
      categories: categories ?? this.categories,
      publishedAt: publishedAt ?? this.publishedAt,
      filePath: filePath ?? this.filePath,
    );
  }

  // Helper method to check if book belongs to a category
  bool hasCategory(String categoryId) => categories.contains(categoryId);

  // Helper method to get publish year
  int get publishYear => publishedAt.year;

  // Helper method to get formatted publish date
  String get formattedPublishDate =>
      '${publishedAt.day}/${publishedAt.month}/${publishedAt.year}';
}
