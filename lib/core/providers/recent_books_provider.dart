import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/book.dart';
import '../services/search_service.dart';
import '../api/api_service.dart';
import '../api/api_config.dart';

final recentBooksProvider =
    StateNotifierProvider<RecentBooksNotifier, AsyncValue<List<Book>>>((ref) {
  final apiService = ref.read(apiServiceProvider);
  final searchService = SearchService(apiService);
  return RecentBooksNotifier(searchService);
});

class RecentBooksNotifier extends StateNotifier<AsyncValue<List<Book>>> {
  final SearchService _searchService;
  static const String _recentBooksKey = 'recent_books';
  static const int _maxRecentBooks = 5;

  RecentBooksNotifier(this._searchService) : super(const AsyncValue.loading()) {
    _initializeRecentBooks();
  }

  Future<void> _initializeRecentBooks() async {
    try {
      // First load from local storage for immediate display
      await _loadFromLocalStorage();
      
      // Then fetch from API and merge with local
      await _fetchAndMergeRecentBooks();
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  Future<void> _loadFromLocalStorage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final recentBooksJson = prefs.getStringList(_recentBooksKey) ?? [];
      final recentBooks = recentBooksJson
          .map((json) => Book.fromJson(jsonDecode(json)))
          .toList();
      state = AsyncValue.data(recentBooks);
    } catch (error) {
      print('Error loading from local storage: $error');
      state = const AsyncValue.data([]);
    }
  }

  Future<void> _fetchAndMergeRecentBooks() async {
    try {
      final apiBooks = await _searchService.getRecentBooks();
      final currentBooks = state.value ?? [];
      
      // Merge API books with local books, prioritizing API data
      final mergedBooks = [...apiBooks];
      
      // Add local books that aren't in the API response
      for (final localBook in currentBooks) {
        if (!mergedBooks.any((book) => book.id == localBook.id)) {
          mergedBooks.add(localBook);
        }
      }

      // Keep only the most recent books
      final finalBooks = mergedBooks.take(_maxRecentBooks).toList();
      
      // Update local storage
      final prefs = await SharedPreferences.getInstance();
      final recentBooksJson = finalBooks
          .map((book) => jsonEncode(book.toJson()))
          .toList();
      await prefs.setStringList(_recentBooksKey, recentBooksJson);
      
      state = AsyncValue.data(finalBooks);
    } catch (error) {
      print('Error fetching recent books from API: $error');
      // Keep the current state if API fails
    }
  }

  Future<void> addRecentBook(Book book) async {
    try {
      final currentBooks = state.value ?? [];
      // Remove the book if it already exists to avoid duplicates
      currentBooks.removeWhere((b) => b.id == book.id);
      // Add the new book at the beginning
      currentBooks.insert(0, book);
      // Keep only the most recent books
      if (currentBooks.length > _maxRecentBooks) {
        currentBooks.removeLast();
      }
      
      // Update local storage
      final prefs = await SharedPreferences.getInstance();
      final recentBooksJson = currentBooks
          .map((book) => jsonEncode(book.toJson()))
          .toList();
      await prefs.setStringList(_recentBooksKey, recentBooksJson);
      
      // Update state
      state = AsyncValue.data(currentBooks);

      // Sync with API
      await _searchService.updateBookProgress(book.id, DateTime.now());
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  Future<void> refresh() async {
    await _fetchAndMergeRecentBooks();
  }
}
