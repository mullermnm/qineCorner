import 'package:qine_corner/core/api/api_service.dart';
import 'package:qine_corner/core/models/discussion.dart';

class DiscussionService {
  final ApiService _apiService;

  DiscussionService(this._apiService);

  Future<List<Discussion>> getDiscussions(String bookClubId) async {
    try {
      final response =
          await _apiService.get('/book-clubs/$bookClubId/discussions');

      // Handle paginated response
      if (response['data'] is Map && response['data']['data'] is List) {
        final discussionsList = response['data']['data'] as List;
        return discussionsList.map((json) => Discussion.fromJson(json)).toList();
      } else if (response['data'] is List) {
        // Handle direct list response
        final discussionsList = response['data'] as List;
        return discussionsList.map((json) => Discussion.fromJson(json)).toList();
      }
      
      // Return empty list if no valid data
      return [];
    } catch (e) {
      print('Error fetching discussions: $e');
      rethrow;
    }
  }

  Future<Discussion> createDiscussion(
      String bookClubId, String title, String content) async {
    try {
      final response = await _apiService.post(
        '/book-clubs/$bookClubId/discussions',
        body: {
          'title': title,
          'content': content,
        },
      );
      
      if (response['data'] is Map) {
        return Discussion.fromJson(response['data']);
      }
      throw Exception('Invalid response format');
    } catch (e) {
      print('Error creating discussion: $e');
      rethrow;
    }
  }

  Future<Discussion> updateDiscussion(
    String bookClubId,
    String discussionId,
    String title,
    String content,
  ) async {
    try {
      final response = await _apiService.put(
        '/book-clubs/$bookClubId/discussions/$discussionId',
        body: {
          'title': title,
          'content': content,
        },
      );
      
      if (response['data'] is Map) {
        return Discussion.fromJson(response['data']);
      }
      throw Exception('Invalid response format');
    } catch (e) {
      print('Error updating discussion: $e');
      rethrow;
    }
  }

  Future<void> deleteDiscussion(String bookClubId, String discussionId) async {
    try {
      await _apiService
          .delete('/book-clubs/$bookClubId/discussions/$discussionId');
    } catch (e) {
      print('Error deleting discussion: $e');
      rethrow;
    }
  }
}
