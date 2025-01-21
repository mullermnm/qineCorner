class Category {
  final String id;
  final String name;
  final String? icon;
  final int? booksCount;

  Category({
    required this.id,
    required this.name,
    this.icon,
    this.booksCount,
  });

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      icon: json['icon']?.toString(),
      booksCount: json['booksCount'] != null 
          ? int.tryParse(json['booksCount'].toString()) ?? 0 
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'icon': icon,
      'booksCount': booksCount,
    };
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Category &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          name == other.name;

  @override
  int get hashCode => id.hashCode ^ name.hashCode;
}
