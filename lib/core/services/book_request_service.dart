import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qine_corner/core/api/api_service.dart';
import 'package:qine_corner/core/models/book_request.dart';
import 'package:qine_corner/core/api/api_config.dart';

final bookRequestServiceProvider =
    Provider((ref) => BookRequestService(ref.read(apiServiceProvider)));

class BookRequestService {
  final ApiService _apiService;

  BookRequestService(this._apiService);

  Future<void> submitRequest({
    required String userId,
    required String title,
    String? author,
  }) async {
    try {
      final response = await _apiService.post(
        ApiConfig.bookRequests,
        body: {
          'user_id': userId,
          'title': title,
          'author': author,
        },
      );
      print('Book request response: $response');
    } catch (e) {
      print('Error submitting book request: $e');
      throw Exception('Failed to submit book request: $e');
    }
  }

  Future<List<BookRequest>> getUserRequests(String userId) async {
    try {
      final response = await _apiService.get('${ApiConfig.bookRequests}/user/$userId');
      final List<dynamic> data = response['data'] as List;
      return data.map((json) => BookRequest.fromJson(json)).toList();
    } catch (e) {
      print('Error fetching user book requests: $e');
      throw Exception('Failed to fetch user book requests: $e');
    }
  }

  Future<void> deleteRequest(String requestId) async {
    try {
      await _apiService.delete('${ApiConfig.bookRequests}/$requestId');
    } catch (e) {
      print('Error deleting book request: $e');
      throw Exception('Failed to delete book request: $e');
    }
  }
}
