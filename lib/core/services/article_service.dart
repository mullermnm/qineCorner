import 'package:qine_corner/core/models/article.dart';
import 'package:qine_corner/core/services/api_service.dart';

class ArticleService {
  final ApiService _api;

  ArticleService(this._api);

  Future<List<Article>> getFeaturedArticles() async {
    final response = await _api.get('/articles/featured');
    return (response['data'] as List)
        .map((json) => Article.fromJson(json))
        .toList();
  }

  Future<List<Article>> getArticles({
    String? category,
    String? query,
    int page = 1,
    int limit = 10,
  }) async {
    final queryParams = {
      if (category != null) 'category': category,
      if (query != null) 'q': query,
      'page': page.toString(),
      'limit': limit.toString(),
    };

    final response = await _api.get('/articles?${Uri(queryParameters: queryParams)}');
    return (response['data'] as List)
        .map((json) => Article.fromJson(json))
        .toList();
  }

  Future<Article> getArticleDetails(String articleId) async {
    final response = await _api.get('/articles/$articleId');
    return Article.fromJson(response['data']);
  }

  Future<Article> createArticle(Map<String, dynamic> articleData) async {
    final response = await _api.post('/articles', articleData);
    return Article.fromJson(response['data']);
  }

  Future<Article> updateArticle(
    String articleId,
    Map<String, dynamic> updates,
  ) async {
    final response = await _api.put('/articles/$articleId', updates);
    return Article.fromJson(response['data']);
  }

  Future<void> deleteArticle(String articleId) async {
    await _api.delete('/articles/$articleId');
  }

  Future<void> likeArticle(String articleId) async {
    await _api.post('/articles/$articleId/like', {});
  }

  Future<void> unlikeArticle(String articleId) async {
    await _api.delete('/articles/$articleId/like');
  }

  Future<void> addComment(String articleId, String content) async {
    await _api.post('/articles/$articleId/comments', {'content': content});
  }

  Future<void> deleteComment(String articleId, String commentId) async {
    await _api.delete('/articles/$articleId/comments/$commentId');
  }

  Future<void> saveArticle(String articleId) async {
    await _api.post('/articles/$articleId/save', {});
  }

  Future<void> unsaveArticle(String articleId) async {
    await _api.delete('/articles/$articleId/save');
  }
}
