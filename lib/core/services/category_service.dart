import '../models/category.dart';
import '../api/api_service.dart';
import '../api/api_config.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final categoryServiceProvider =
    Provider((ref) => CategoryService(ref.read(apiServiceProvider)));

class CategoryService {
  final ApiService _apiService;

  CategoryService(this._apiService);

  Future<List<Category>> getCategories() async {
    try {
      final response = await _apiService.get(ApiConfig.categories);
      final data = ApiConfig.extractData(response);

      if (data is Map && data.containsKey('categories')) {
        final categoriesList = data['categories'] as List;
        return categoriesList
            .map((json) {
              if (json is Map) {
                // Convert to Map<String, dynamic> and ensure id is string
                final categoryJson = Map<String, dynamic>.from(json);
                categoryJson['id'] = categoryJson['id'].toString();
                return Category.fromJson(categoryJson);
              }
              return null;
            })
            .whereType<Category>()
            .toList();
      }

      return [];
    } catch (e) {
      print('Error fetching categories: $e');
      return [];
    }
  }

  Future<Category?> getCategoryById(String id) async {
    try {
      final response = await _apiService.get('${ApiConfig.categories}/$id');
      final data = ApiConfig.extractData(response);
      return Category.fromJson(data);
    } catch (e) {
      print('Error fetching category: $e');
      return null;
    }
  }

  Future<List<Category>> getPopularCategories({int limit = 5}) async {
    try {
      final queryParams = {
        'limit': limit.toString(),
      };

      final response = await _apiService.get(
        '${ApiConfig.categories}/popular',
        queryParams: queryParams,
      );
      final data = ApiConfig.extractData(response);
      return (data as List).map((json) => Category.fromJson(json)).toList();
    } catch (e) {
      print('Error fetching popular categories: $e');
      return [];
    }
  }

  Future<List<Category>> searchCategories(String query) async {
    try {
      final queryParams = {
        'query': query,
      };

      final response = await _apiService.get(
        '${ApiConfig.categories}/search',
        queryParams: queryParams,
      );
      final data = ApiConfig.extractData(response);
      return (data as List).map((json) => Category.fromJson(json)).toList();
    } catch (e) {
      print('Error searching categories: $e');
      return [];
    }
  }

  void clearCache() {
    // Removed cache clearing functionality
  }
}
