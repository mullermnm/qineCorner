import 'package:flutter/foundation.dart';
import 'package:qine_corner/core/models/book.dart';
import 'package:qine_corner/core/models/user.dart';
import 'package:qine_corner/core/models/user_with_role.dart';

@immutable
class BookClub {
  final int id;
  final String name;
  final String description;
  final String? imageUrl;
  final List<String> genres;
  final User owner;
  final List<UserWithRole> members;
  final int memberCount;
  final bool isPrivate;
  final Book? currentBook;
  final DateTime createdAt;
  final DateTime updatedAt;

  const BookClub({
    required this.id,
    required this.name,
    required this.description,
    this.imageUrl,
    required this.genres,
    required this.owner,
    required this.members,
    required this.memberCount,
    required this.isPrivate,
    this.currentBook,
    required this.createdAt,
    required this.updatedAt,
  });

  factory BookClub.fromJson(Map<String, dynamic> json) {
    return BookClub(
      id: json['id'] as int,
      name: json['name'] as String,
      description: json['description'] as String,
      imageUrl: json['image_url'] as String?,
      genres: List<String>.from(json['genres'] as List),
      owner: User.fromJson(json['owner'] as Map<String, dynamic>),
      members: (json['members'] as List?)
          ?.map((member) => UserWithRole.fromJson(member as Map<String, dynamic>))
          .toList() ?? [],
      memberCount: json['member_count'] as int? ?? 0,
      isPrivate: json['is_private'] as bool? ?? false,
      currentBook: json['current_book'] != null
          ? Book.fromJson(json['current_book'] as Map<String, dynamic>)
          : null,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'image_url': imageUrl,
      'genres': genres,
      'owner': owner.toJson(),
      'members': members.map((member) => member.toJson()).toList(),
      'member_count': memberCount,
      'is_private': isPrivate,
      'current_book': currentBook?.toJson(),
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  BookClub copyWith({
    int? id,
    String? name,
    String? description,
    String? imageUrl,
    List<String>? genres,
    User? owner,
    List<UserWithRole>? members,
    int? memberCount,
    bool? isPrivate,
    Book? currentBook,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return BookClub(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      imageUrl: imageUrl ?? this.imageUrl,
      genres: genres ?? this.genres,
      owner: owner ?? this.owner,
      members: members ?? this.members,
      memberCount: memberCount ?? this.memberCount,
      isPrivate: isPrivate ?? this.isPrivate,
      currentBook: currentBook ?? this.currentBook,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
