import '../models/author.dart';
import '../api/api_service.dart';
import '../api/api_config.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final authorServiceProvider = Provider((ref) => AuthorService(ref.read(apiServiceProvider)));

class AuthorService {
  final ApiService _apiService;

  AuthorService(this._apiService);

  Future<List<Author>> getAllAuthors() async {
    try {
      final response = await _apiService.get('/authors');
      return (response['data'] as List)
          .map((json) => Author.fromJson(json))
          .toList();
    } catch (e) {
      print('Error fetching authors: $e');
      return [];
    }
  }

  Future<Author?> getAuthorById(String id) async {
    try {
      final response = await _apiService.get('/authors/$id');
      return Author.fromJson(response['data']);
    } catch (e) {
      print('Error fetching author: $e');
      return null;
    }
  }

  Future<List<Author>> searchAuthors(String query) async {
    try {
      final response = await _apiService.get(
        '/authors/search',
        queryParams: {'query': query},
      );
      return (response['data'] as List)
          .map((json) => Author.fromJson(json))
          .toList();
    } catch (e) {
      print('Error searching authors: $e');
      return [];
    }
  }

  Future<List<Author>> getAuthorsByGenre(String genre) async {
    try {
      final response = await _apiService.get(
        '/authors',
        queryParams: {'genre': genre},
      );
      return (response['data'] as List)
          .map((json) => Author.fromJson(json))
          .toList();
    } catch (e) {
      print('Error fetching authors by genre: $e');
      return [];
    }
  }

  void clearCache() {
    // This method is not implemented as caching is removed
  }
}
