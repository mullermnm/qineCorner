class Category {
  final String id;
  final String name;
  final String icon;
  final int bookCount;

  const Category({
    required this.id,
    required this.name,
    required this.icon,
    required this.bookCount,
  });

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: json['id'] as String,
      name: json['name'] as String,
      icon: json['icon'] as String,
      bookCount: json['bookCount'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'icon': icon,
      'bookCount': bookCount,
    };
  }
}
