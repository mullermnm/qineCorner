import '../models/category.dart';

class CategoryService {
  // Simulating backend data
  final List<Category> _categories = [
    Category(
      id: '1',
      name: 'ልቦለድ',
      icon: '📚',
      bookCount: 150,
    ),
    Category(
      id: '2',
      name: 'ታሪክ',
      icon: '🏛️',
      bookCount: 85,
    ),
    Category(
      id: '3',
      name: 'ፍቅር',
      icon: '❤️',
      bookCount: 120,
    ),
    Category(
      id: '4',
      name: 'ትምህርት',
      icon: '📖',
      bookCount: 95,
    ),
    Category(
      id: '5',
      name: 'ሃይማኖት',
      icon: '🕌',
      bookCount: 110,
    ),
    Category(
      id: '6',
      name: 'ልጆች',
      icon: '👶',
      bookCount: 75,
    ),
    Category(
      id: '7',
      name: 'ሳይንስ',
      icon: '🔬',
      bookCount: 60,
    ),
  ];

  // Simulate fetching categories from backend
  Future<List<Category>> getCategories() async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 800));
    return _categories;
  }

  // Get category by ID
  Future<Category?> getCategoryById(String id) async {
    await Future.delayed(const Duration(milliseconds: 300));
    return _categories.firstWhere(
      (category) => category.id == id,
      orElse: () => throw Exception('Category not found'),
    );
  }

  // Get popular categories (those with most books)
  Future<List<Category>> getPopularCategories({int limit = 5}) async {
    await Future.delayed(const Duration(milliseconds: 500));
    final sorted = List<Category>.from(_categories)
      ..sort((a, b) => b.bookCount.compareTo(a.bookCount));
    return sorted.take(limit).toList();
  }
}
