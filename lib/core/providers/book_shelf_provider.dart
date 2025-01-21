import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/book.dart';

enum BookShelf {
  currentlyReading,
  toRead,
  finished,
}

final bookShelfProvider =
    StateNotifierProvider<BookShelfNotifier, AsyncValue<Map<BookShelf, List<Book>>>>((ref) {
  return BookShelfNotifier();
});

class BookShelfNotifier extends StateNotifier<AsyncValue<Map<BookShelf, List<Book>>>> {
  BookShelfNotifier() : super(const AsyncValue.loading()) {
    _loadShelves();
  }

  static const String _shelvesKey = 'book_shelves';

  Future<void> _loadShelves() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final shelvesJson = prefs.getString(_shelvesKey);
      
      if (shelvesJson == null) {
        state = AsyncValue.data({
          BookShelf.currentlyReading: [],
          BookShelf.toRead: [],
          BookShelf.finished: [],
        });
        return;
      }

      final Map<String, dynamic> shelvesMap = jsonDecode(shelvesJson);
      final shelves = {
        for (var shelf in BookShelf.values)
          shelf: (shelvesMap[shelf.toString()] as List?)
              ?.map((bookJson) => Book.fromJson(bookJson))
              .toList() ??
              [],
      };
      
      state = AsyncValue.data(shelves);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  Future<void> addBookToShelf(Book book, BookShelf shelf) async {
    try {
      final currentShelves = state.value ?? {
        BookShelf.currentlyReading: [],
        BookShelf.toRead: [],
        BookShelf.finished: [],
      };

      // Remove book from all shelves first
      for (var currentShelf in BookShelf.values) {
        currentShelves[currentShelf]?.removeWhere((b) => b.id == book.id);
      }

      // Add to new shelf
      currentShelves[shelf]?.add(book);

      // Save to SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      final shelvesMap = {
        for (var entry in currentShelves.entries)
          entry.key.toString(): entry.value.map((b) => b.toJson()).toList(),
      };
      await prefs.setString(_shelvesKey, jsonEncode(shelvesMap));

      state = AsyncValue.data(currentShelves);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  Future<void> removeBookFromShelf(Book book, BookShelf shelf) async {
    try {
      final currentShelves = state.value;
      if (currentShelves == null) return;

      currentShelves[shelf]?.removeWhere((b) => b.id == book.id);

      // Save to SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      final shelvesMap = {
        for (var entry in currentShelves.entries)
          entry.key.toString(): entry.value.map((b) => b.toJson()).toList(),
      };
      await prefs.setString(_shelvesKey, jsonEncode(shelvesMap));

      state = AsyncValue.data(currentShelves);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }
}
