import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qine_corner/core/api/api_service.dart';
import 'package:qine_corner/features/book_rating/domain/book_rating_model.dart';

final bookRatingServiceProvider =
    Provider((ref) => BookRatingService(ref.read(apiServiceProvider)));

class BookRatingService {
  final ApiService _apiService;

  BookRatingService(this._apiService);

  /// Get all ratings for a book
  Future<List<BookRating>> getBookRatings(String bookId) async {
    try {
      final response = await _apiService.get('/book-ratings/book/$bookId');
      final List<dynamic> data = response['data']['ratings'];
      return data.map((json) => BookRating.fromJson(json)).toList();
    } catch (e) {
      rethrow;
    }
  }

  /// Get the current user's rating for a book
  Future<BookRating?> getUserBookRating(String bookId) async {
    try {
      final response = await _apiService.get('/book-ratings/user/book/$bookId');
      if (response['data'] == null) return null;
      return BookRating.fromJson(response['data']['rating']);
    } catch (e) {
      // If 404 (not found), return null instead of throwing
      if (e.toString().contains('404')) {
        return null;
      }
      rethrow;
    }
  }

  /// Rate a book or update an existing rating
  Future<BookRating> rateBook(String bookId, double rating, {String? review}) async {
    try {
      final response = await _apiService.post(
        '/book-ratings',
        body: {
          'book_id': bookId,
          'rating': rating,
          if (review != null) 'review': review,
        },
      );
      return BookRating.fromJson(response['data']['rating']);
    } catch (e) {
      rethrow;
    }
  }

  /// Delete a rating
  Future<void> deleteRating(String bookId) async {
    try {
      await _apiService.delete('/book-ratings/book/$bookId');
    } catch (e) {
      rethrow;
    }
  }

  /// Get all ratings by the current user
  Future<List<BookRating>> getUserRatings() async {
    try {
      final response = await _apiService.get('/book-ratings/user');
      final List<dynamic> data = response['data']['ratings'];
      return data.map((json) => BookRating.fromJson(json)).toList();
    } catch (e) {
      rethrow;
    }
  }
}
