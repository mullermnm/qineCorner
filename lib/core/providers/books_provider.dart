import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/book.dart';
import '../services/search_service.dart';

class BooksNotifier extends StateNotifier<AsyncValue<List<Book>>> {
  BooksNotifier() : super(const AsyncValue.loading()) {
    loadInitialBooks();
  }

  final _searchService = SearchService();
  static const _itemsPerPage = 9;
  int _currentPage = 0;
  String? _currentCategory;

  Future<void> loadInitialBooks() async {
    state = const AsyncValue.loading();
    try {
      final books = await _fetchBooks(0);
      state = AsyncValue.data(books);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> loadMoreBooks() async {
    if (state.isLoading || state.hasError) return;

    final currentBooks = state.value ?? [];
    _currentPage++;

    try {
      final newBooks = await _fetchBooks(_currentPage);
      if (newBooks.isEmpty) {
        _currentPage--; // Revert if no more books
        return;
      }
      state = AsyncValue.data([...currentBooks, ...newBooks]);
    } catch (e, st) {
      _currentPage--; // Revert page increment on error
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> filterByCategory(String? category) async {
    if (_currentCategory == category) return;

    _currentCategory = category;
    _currentPage = 0;
    await loadInitialBooks();
  }

  Future<List<Book>> _fetchBooks(int page) async {
    // Simulate API call with delay
    await Future.delayed(const Duration(milliseconds: 800));

    final List<Book> books;
    if (_currentCategory == null) {
      books = await _searchService.getPopularBooks();
    } else {
      books = await _searchService.getBooksByCategory(_currentCategory!);
    }

    // Calculate pagination slice
    final start = page * _itemsPerPage;
    final end = start + _itemsPerPage;
    
    if (start >= books.length) {
      return [];
    }

    return books.sublist(
      start,
      end > books.length ? books.length : end,
    );
  }
}

final booksProvider =
    StateNotifierProvider<BooksNotifier, AsyncValue<List<Book>>>((ref) {
  return BooksNotifier();
});
