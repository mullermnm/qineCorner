import 'dart:io';
import 'package:qine_corner/core/api/api_service.dart';
import 'package:qine_corner/core/models/article.dart';

class ArticleService {
  final ApiService _apiService;

  ArticleService(this._apiService);

  Future<List<Article>> getArticles(
      {String? authorId,
      String? category,
      String? status,
      String? articleId,
      String? searchQuery}) async {
    try {
      final queryParams = {
        if (authorId != null) 'authorId': authorId,
        if (category != null) 'category': category,
        if (status != null) 'status': status,
        if (articleId != null) 'articleId': articleId,
        if (searchQuery != null) 'search': searchQuery,
      };
      final endpoint = '/articles${_buildQueryString(queryParams)}';
      final response = await _apiService.get(endpoint);
      print('Article response: $response');

      final articles = response['articles'] as List;
      return articles
          .map((json) => Article.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      print('Error fetching articles: $e');
      return [];
    }
  }

  Future<List<Article>> getFeaturedArticles() async {
    try {
      final response = await _apiService.get('/articles/featured');
      final dynamic articles = response['articles'] ?? response['data'] ?? [];
      if (articles is List) {
        return articles
            .map((json) => Article.fromJson(json as Map<String, dynamic>))
            .toList();
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  Future<Article?> getArticleDetails(String id) async {
    try {
      final response = await _apiService.get('/articles/$id');
      final dynamic article = response['article'] ?? response['data'];
      if (article != null) {
        return Article.fromJson(article as Map<String, dynamic>);
      }
      return null;
    } catch (e) {
      rethrow;
    }
  }

  Future<Article> createArticle(Article article) async {
    final response =
        await _apiService.post('/articles', body: article.toJson());
    return Article.fromJson(response['article'] ?? response['data']);
  }

  Future<Article> updateArticle(String id, Article article) async {
    final response =
        await _apiService.put('/articles/$id', body: article.toJson());
    return Article.fromJson(response['article'] ?? response['data']);
  }

  Future<void> deleteArticle(String id) async {
    await _apiService.delete('/articles/$id');
  }

  Future<String> uploadMedia(File file) async {
    return await _apiService.uploadMedia('articles/media', file);
  }

  Future<void> publishDraft(String id) async {
    await _apiService.post('/articles/$id/publish');
  }

  Future<void> moveToDraft(String id) async {
    await _apiService.post('/articles/$id/draft');
  }

  Future<void> likeArticle(String id) async {
    await _apiService.post('/articles/$id/like');
  }

  Future<void> unlikeArticle(String id) async {
    await _apiService.delete('/articles/$id/like');
  }

  Future<void> saveArticle(String id) async {
    await _apiService.post('/articles/$id/save');
  }

  Future<void> unsaveArticle(String id) async {
    await _apiService.delete('/articles/$id/save');
  }

  Future<void> shareArticle(String id) async {
    await _apiService.post('/articles/$id/share');
  }

  Future<void> viewArticle(String id) async {
    await _apiService.post('/articles/$id/view');
  }

  String _buildQueryString(Map<String, String> params) {
    if (params.isEmpty) return '';
    return '?' + params.entries.map((e) => '${e.key}=${e.value}').join('&');
  }
}
