import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qine_corner/core/providers/library_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/book.dart';

class FavoriteNotifier extends StateNotifier<List<Book>> {
  final SharedPreferences prefs;
  static const String _key = 'favorite_books';

  FavoriteNotifier(this.prefs) : super([]) {
    _loadFavorites();
  }

  void _loadFavorites() {
    try {
      final String? favoritesJson = prefs.getString(_key);
      if (favoritesJson != null) {
        final List<dynamic> decoded = jsonDecode(favoritesJson);
        state = decoded.map((item) => Book.fromJson(item)).toList();
      }
    } catch (e) {
      print('Error loading favorites: $e');
      state = [];
    }
  }

  Future<void> _saveFavorites() async {
    try {
      final String encoded =
          jsonEncode(state.map((book) => book.toJson()).toList());
      await prefs.setString(_key, encoded);
    } catch (e) {
      print('Error saving favorites: $e');
    }
  }

  bool isFavorite(String bookId) {
    return state.any((book) => book.id == bookId);
  }

  Future<void> toggleFavorite(Book book) async {
    if (isFavorite(book.id)) {
      state = state.where((b) => b.id != book.id).toList();
    } else {
      state = [...state, book];
    }
    await _saveFavorites();
  }
}

final favoriteProvider =
    StateNotifierProvider<FavoriteNotifier, List<Book>>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  return FavoriteNotifier(prefs);
});
