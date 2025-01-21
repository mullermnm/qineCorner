import 'dart:convert';

class Note {
  final String id;
  final String bookTitle;
  final int pageNumber;
  final String noteText;
  final String? highlightedText;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final List<String> tags;
  final bool isImportant;
  final Map<String, dynamic>? formatting; // Stores rich text formatting data
  final String? bookId; // Added to link back to the specific book

  Note({
    required this.id,
    required this.bookTitle,
    required this.pageNumber,
    required this.noteText,
    this.highlightedText,
    required this.createdAt,
    this.updatedAt,
    this.tags = const [],
    this.isImportant = false,
    this.formatting,
    this.bookId,
  });

  factory Note.fromJson(Map<String, dynamic> json) {
    return Note(
      id: json['id'],
      bookTitle: json['bookTitle'],
      pageNumber: json['pageNumber'],
      noteText: json['noteText'],
      highlightedText: json['highlightedText'] ?? '', 
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: json['updatedAt'] != null ? DateTime.parse(json['updatedAt']) : null,
      tags: List<String>.from(json['tags'] ?? []),
      isImportant: json['isImportant'] ?? false,
      formatting: json['formatting'],
      bookId: json['bookId'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'bookTitle': bookTitle,
      'pageNumber': pageNumber,
      'noteText': noteText,
      'highlightedText': highlightedText,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
      'tags': tags,
      'isImportant': isImportant,
      'formatting': formatting,
      'bookId': bookId,
    };
  }

  Note copyWith({
    String? id,
    String? bookTitle,
    int? pageNumber,
    String? noteText,
    String? highlightedText,
    DateTime? createdAt,
    DateTime? updatedAt,
    List<String>? tags,
    bool? isImportant,
    Map<String, dynamic>? formatting,
    String? bookId,
  }) {
    return Note(
      id: id ?? this.id,
      bookTitle: bookTitle ?? this.bookTitle,
      pageNumber: pageNumber ?? this.pageNumber,
      noteText: noteText ?? this.noteText,
      highlightedText: highlightedText ?? this.highlightedText,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      tags: tags ?? this.tags,
      isImportant: isImportant ?? this.isImportant,
      formatting: formatting ?? this.formatting,
      bookId: bookId ?? this.bookId,
    );
  }
}
