import 'package:qine_corner/core/models/category.dart';

import 'author.dart';

class Book {
  final String id;
  final String title;
  final Author author;
  final String description;
  final String coverUrl;
  final double? rating;  // Make rating optional
  final List<Category> categories; // List of category IDs
  final DateTime publishedAt;
  final String filePath; // Path to the PDF file

  const Book({
    required this.id,
    required this.title,
    required this.author,
    required this.description,
    required this.coverUrl,
    this.rating = 0.0,  // Default to 0.0 if not provided
    required this.categories,
    required this.publishedAt,
    required this.filePath,
  });

  // Add fromJson constructor for future API integration
  factory Book.fromJson(Map<dynamic, dynamic> json) {
    try {
      // Handle categories that might be integers, strings, or null
      List<Category> parseCategories(dynamic categories) {
        if (categories == null) return [];
        if (categories is List) {
          return categories.map((category) {
            // Handle different category formats
            if (category is Map) {
              // Create a Category from the map
              return Category(
                id: category['id']?.toString() ?? '',
                name: category['name']?.toString() ?? 'Unknown',
                icon: category['icon']?.toString() ?? 'category',
                booksCount: category['books_count'] ?? 0,
              );
            } else if (category is String) {
              // Create a basic Category from a string ID or name
              return Category(
                id: category,
                name: category,
                icon: 'category',
                booksCount: 0,
              );
            } else if (category is Category) {
              // Already a Category object
              return category;
            }
            // Default fallback
            return Category(
              id: '0',
              name: 'Unknown',
              icon: 'category',
              booksCount: 0,
            );
          }).toList();
        }
        return [];
      }

      return Book(
        id: json['id']?.toString() ?? '',
        title: json['title']?.toString() ?? '',
        author: Author.fromJson(json['author'] as Map<String, dynamic>),
        description: json['description']?.toString() ?? '',
        coverUrl: json['cover_url']?.toString() ?? '',
        rating: (json['rating'] as num?)?.toDouble() ?? 0.0,
        categories: parseCategories(json['categories']),
        publishedAt: json['published_at'] != null 
            ? DateTime.parse(json['published_at'] as String)
            : DateTime.now(),
        filePath: json['file_path']?.toString() ?? '',
      );
    } catch (e, stack) {
      print('Error parsing Book JSON: $e');
      print('Stack trace: $stack');
      print('Problematic JSON: $json');
      rethrow;
    }
  }

  // Add toJson method for future API integration
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'author': author.toJson(),
      'description': description,
      'cover_url': coverUrl,  // Changed to match API
      'rating': rating,
      'categories': categories,
      'published_at': publishedAt.toIso8601String(),  // Changed to match API
      'file_path': filePath,  // Changed to match API
    };
  }

  // Add copyWith method for immutable updates
  Book copyWith({
    String? id,
    String? title,
    Author? author,
    String? description,
    String? coverUrl,
    double? rating,
    List<Category>? categories,
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
