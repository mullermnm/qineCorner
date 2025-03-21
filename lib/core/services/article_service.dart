import 'dart:io';
import 'dart:convert';
import 'package:qine_corner/core/api/api_service.dart';
import 'package:qine_corner/core/models/article.dart';
import 'package:qine_corner/core/models/comment.dart';

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
      print('Articles: $articles');
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
    try {
      // Ensure content is properly formatted
      var content = article.content;
      // if (content is String) {
      //   try {
      //     // If it's a Delta JSON string, parse it
      //     content = jsonDecode(content);
      //   } catch (e) {
      //     // If parsing fails, create a simple Delta
      //     content = [{"insert": content}] as String;
      //   }
      // }

      final body = {
        ...article.toJson(),
        'content': content, // Send as parsed JSON object
      };

      print('Sending article body: ${jsonEncode(body)}'); // Debug log
      
      final response = await _apiService.post('/articles', body: body);
      return Article.fromJson(response['article'] ?? response['data']);
    } catch (e) {
      print('Error creating article: $e');
      rethrow;
    }
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

  Future<List<Comment>> getComments(String articleId) async {
    try {
      final response = await _apiService.get('/articles/$articleId/comments');
      
      final List<dynamic> commentsList = response['data'] ?? response['comments'] ?? [];
      
      return commentsList
          .map((json) => Comment.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      print('Error fetching comments: $e');
      return [];
    }
  }

  Future<Comment> addComment(String articleId, String content, {String? parentId}) async {
    try {
      // If it's a reply, use the reply endpoint
      final endpoint = parentId != null 
          ? '/comments/$parentId/replies'
          : '/articles/$articleId/comments';

      final response = await _apiService.post(
        endpoint,
        body: {
          'content': content,
          if (parentId == null) 'article_id': articleId,
        },
      );

      print('Add comment response: $response'); // Debug log

      final commentData = response['data'] ?? response['comment'];
      if (commentData == null) {
        throw Exception('Invalid response: No comment data received');
      }

      return Comment.fromJson(commentData as Map<String, dynamic>);
    } catch (e) {
      print('Error adding comment: $e');
      throw Exception('Error adding comment: $e');
    }
  }

  Future<void> likeComment(String commentId) async {
    try {
      final response = await _apiService.post('/comments/$commentId/like');
      if (response == null || response['success'] != true) {
        throw Exception('Failed to like comment');
      }
    } catch (e) {
      print('Error liking comment: $e');
      throw Exception('Error liking comment: $e');
    }
  }

  Future<void> unlikeComment(String commentId) async {
    try {
      final response = await _apiService.delete('/comments/$commentId/like');
      if (response == null || response['success'] != true) {
        throw Exception('Failed to unlike comment');
      }
    } catch (e) {
      print('Error unliking comment: $e');
      throw Exception('Error unliking comment: $e');
    }
  }

  Future<void> deleteComment(String commentId) async {
    try {
      await _apiService.delete('/comments/$commentId');
    } catch (e) {
      print('Error deleting comment: $e');
      throw Exception('Error deleting comment: $e');
    }
  }

  Future<Article> getArticle(String id) async {
    try {
      final response = await _apiService.get('/articles/$id');
      final article = Article.fromJson(response['data']);
      
      // Get comments count
      final commentsResponse = await _apiService.get('/articles/$id/comments');
      final commentsList = commentsResponse['data'] ?? [];
      int totalComments = commentsList.length;
      
      
      // Return article with updated comment count
      return article.copyWith(comments: totalComments);
    } catch (e) {
      print('Error getting article: $e');
      rethrow;
    }
  }

  Future<List<Article>> getMyDrafts() async {
    try {
      final response = await _apiService.get('/articles/drafts');
      final articles = response['data'] ?? [];
      return (articles as List)
          .map((json) => Article.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      print('Error fetching drafts: $e');
      return [];
    }
  }

  Future<List<Article>> getMyArticles() async {
    try {
      final response = await _apiService.get('/articles/my');
      final articles = response['data'] ?? [];
      return (articles as List)
          .map((json) => Article.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      print('Error fetching my articles: $e');
      return [];
    }
  }

  String _buildQueryString(Map<String, String> params) {
    if (params.isEmpty) return '';
    return '?' + params.entries.map((e) => '${e.key}=${e.value}').join('&');
  }
}
