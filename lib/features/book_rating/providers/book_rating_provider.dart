import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qine_corner/core/api/api_service.dart';
import 'package:qine_corner/core/services/book_rating_service.dart';
import 'package:qine_corner/features/book_rating/domain/book_rating_model.dart';

final bookRatingServiceProvider = Provider((ref) => BookRatingService(ref.read(apiServiceProvider)));

/// Provider for all ratings of a specific book
final bookRatingsProvider = FutureProvider.family<List<BookRating>, String>((ref, bookId) async {
  final service = ref.watch(bookRatingServiceProvider);
  return service.getBookRatings(bookId);
});

/// Provider for the current user's rating of a specific book
final userBookRatingProvider = FutureProvider.family<BookRating?, String>((ref, bookId) async {
  final service = ref.watch(bookRatingServiceProvider);
  return service.getUserBookRating(bookId);
});

/// Provider for all ratings by the current user
final userRatingsProvider = FutureProvider<List<BookRating>>((ref) async {
  final service = ref.watch(bookRatingServiceProvider);
  return service.getUserRatings();
});

/// Notifier for managing book rating operations
class BookRatingNotifier extends StateNotifier<AsyncValue<void>> {
  final BookRatingService _service;
  final Ref _ref;
  
  BookRatingNotifier(this._service, this._ref) : super(const AsyncValue.data(null));

  Future<void> rateBook(String bookId, double rating, {String? review}) async {
    state = const AsyncValue.loading();
    try {
      await _service.rateBook(bookId, rating, review: review);
      // Invalidate related providers to refresh data
      _ref.invalidate(userBookRatingProvider(bookId));
      _ref.invalidate(bookRatingsProvider(bookId));
      _ref.invalidate(userRatingsProvider);
      state = const AsyncValue.data(null);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<void> deleteRating(String bookId) async {
    state = const AsyncValue.loading();
    try {
      await _service.deleteRating(bookId);
      // Invalidate related providers to refresh data
      _ref.invalidate(userBookRatingProvider(bookId));
      _ref.invalidate(bookRatingsProvider(bookId));
      _ref.invalidate(userRatingsProvider);
      state = const AsyncValue.data(null);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }
}

final bookRatingNotifierProvider = StateNotifierProvider<BookRatingNotifier, AsyncValue<void>>((ref) {
  return BookRatingNotifier(ref.watch(bookRatingServiceProvider), ref);
});
