import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/category.dart';
import '../services/category_service.dart';
import '../api/api_service.dart';

final categoriesProvider =
    StateNotifierProvider<CategoriesNotifier, AsyncValue<List<Category>>>(
        (ref) {
  final apiService = ref.read(apiServiceProvider);
  final categoryService = CategoryService(apiService);
  return CategoriesNotifier(categoryService);
});

class CategoriesNotifier extends StateNotifier<AsyncValue<List<Category>>> {
  final CategoryService _categoryService;
  List<Category>? _cachedCategories;

  CategoriesNotifier(this._categoryService)
      : super(const AsyncValue.loading()) {
    loadCategories();
  }

  Future<void> loadCategories() async {
    if (_cachedCategories != null) {
      state = AsyncValue.data(_cachedCategories!);
      return;
    }

    state = const AsyncValue.loading();
    try {
      final categories = await _categoryService.getCategories();
      _cachedCategories = categories;
      state = AsyncValue.data(categories);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<Category?> getCategoryById(String id) async {
    try {
      // Check cache first
      if (_cachedCategories != null) {
        return _cachedCategories!.firstWhere(
          (category) => category.id == id,
          orElse: () => throw Exception('Category not found'),
        );
      }

      return await _categoryService.getCategoryById(id);
    } catch (e) {
      print('Error fetching category: $e');
      return null;
    }
  }

  Future<void> refresh() async {
    _cachedCategories = null;
    await loadCategories();
  }
}

final categoryByIdProvider =
    Provider.family<Category?, String>((ref, categoryId) {
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
