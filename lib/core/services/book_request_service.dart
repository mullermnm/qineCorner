import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qine_corner/core/api/api_service.dart';
import 'package:qine_corner/core/models/book_request.dart';

final bookRequestServiceProvider =
    Provider((ref) => BookRequestService(ref.read(apiServiceProvider)));

class BookRequestService {
  final ApiService _apiService;

  BookRequestService(this._apiService);

  Future<void> submitRequest(BookRequest request) async {
    try {
      await _apiService.post(
        '/book-requests',
        body: request.toJson(),
      );
    } catch (e) {
      throw Exception('Failed to submit book request: $e');
    }
  }

  Future<List<BookRequest>> getUserRequests(String userId) async {
    try {
      final response = await _apiService.get('/book-requests/user/$userId');
      return (response as List)
          .map((json) => BookRequest.fromJson(json))
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch user book requests: $e');
    }
  }
}
