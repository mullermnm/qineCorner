import 'package:qine_corner/core/models/book.dart';

class Library {
  final String id;
  final String name;
  final List<Book> books;
  final DateTime createdAt;
  final DateTime updatedAt;

  Library({
    required this.id,
    required this.name,
    required this.books,
    required this.createdAt,
    required this.updatedAt,
  });

  int get bookCount => books.length;

  List<Book> get previewBooks => books.take(4).toList();

  // Convert Library to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'books': books.map((book) => book.toJson()).toList(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  // Create Library from JSON
  factory Library.fromJson(Map<String, dynamic> json) {
    return Library(
      id: json['id'],
      name: json['name'],
      books: (json['books'] as List)
          .map((bookJson) => Book.fromJson(bookJson))
          .toList(),
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }

  Library copyWith({
    String? id,
    String? name,
    List<Book>? books,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Library(
      id: id ?? this.id,
      name: name ?? this.name,
      books: books ?? this.books,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
