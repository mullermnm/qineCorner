class Author {
  final String id;
  final String name;
  final String? bio;
  final String? imageUrl;
  final DateTime? birthDate;
  final List<String> genres;

  const Author({
    required this.id,
    required this.name,
    this.bio,
    this.imageUrl,
    this.birthDate,
    this.genres = const [],
  });

  // Add fromJson constructor for future API integration
  factory Author.fromJson(Map<String, dynamic> json) {
    return Author(
      id: json['id'] as String,
      name: json['name'] as String,
      bio: json['bio'] as String?,
      imageUrl: json['imageUrl'] as String?,
      birthDate: json['birthDate'] != null
          ? DateTime.parse(json['birthDate'] as String)
          : null,
      genres: json['genres'] != null
          ? List<String>.from(json['genres'] as List)
          : [],
    );
  }

  // Add toJson method for future API integration
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'bio': bio,
      'imageUrl': imageUrl,
      'birthDate': birthDate?.toIso8601String(),
      'genres': genres,
    };
  }

  // Add copyWith method for immutable updates
  Author copyWith({
    String? id,
    String? name,
    String? bio,
    String? imageUrl,
    DateTime? birthDate,
    List<String>? genres,
  }) {
    return Author(
      id: id ?? this.id,
      name: name ?? this.name,
      bio: bio ?? this.bio,
      imageUrl: imageUrl ?? this.imageUrl,
      birthDate: birthDate ?? this.birthDate,
      genres: genres ?? this.genres,
    );
  }

  // Helper method to get age
  int? get age {
    if (birthDate == null) return null;
    final now = DateTime.now();
    var age = now.year - birthDate!.year;
    if (now.month < birthDate!.month || 
        (now.month == birthDate!.month && now.day < birthDate!.day)) {
      age--;
    }
    return age;
  }

  // Helper method to get formatted birth date
  String? get formattedBirthDate {
    if (birthDate == null) return null;
    return '${birthDate!.day}/${birthDate!.month}/${birthDate!.year}';
  }
}
