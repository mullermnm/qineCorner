import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/category.dart';
import '../services/category_service.dart';

final categoriesProvider = FutureProvider<List<Category>>((ref) async {
  final categoryService = CategoryService();
  return categoryService.getCategories();
});

final categoryByIdProvider = Provider.family<Category?, String>((ref, categoryId) {
  final categoriesAsync = ref.watch(categoriesProvider);
  return categoriesAsync.when(
    data: (categories) {
      try {
        return categories.firstWhere((category) => category.id == categoryId);
      } catch (e) {
        return null;
      }
    },
    loading: () => null,
    error: (_, __) => null,
  );
});
