import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:qine_corner/core/models/book.dart';
import 'package:qine_corner/core/models/library.dart';

// Provider to initialize SharedPreferences
final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError('Initialize in main.dart');
});

class LibraryNotifier extends StateNotifier<List<Library>> {
  final SharedPreferences prefs;
  static const String _key = 'libraries';

  LibraryNotifier(this.prefs) : super([]);

  Future<void> loadInitialData() async {
    try {
      final String? librariesJson = prefs.getString(_key);
      if (librariesJson != null) {
        final List<dynamic> decoded = jsonDecode(librariesJson);
        state = decoded.map((item) => Library.fromJson(item)).toList();
      }
    } catch (e) {
      print('Error loading libraries: $e');
      state = [];
    }
  }

  Future<void> _saveLibraries() async {
    try {
      final String encoded = jsonEncode(state.map((lib) => lib.toJson()).toList());
      await prefs.setString(_key, encoded);
    } catch (e) {
      print('Error saving libraries: $e');
    }
  }

  Future<void> addLibrary(String name, {Book? initialBook}) async {
    final newLibrary = Library(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: name,
      books: initialBook != null ? [initialBook] : [],
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
    state = [...state, newLibrary];
    await _saveLibraries();
  }

  Future<void> deleteLibrary(String libraryId) async {
    state = state.where((lib) => lib.id != libraryId).toList();
    await _saveLibraries();
  }

  Future<void> addBookToLibrary(String libraryId, Book book) async {
    state = state.map((lib) {
      if (lib.id == libraryId) {
        final updatedBooks = [...lib.books, book];
        return lib.copyWith(books: updatedBooks);
      }
      return lib;
    }).toList();
    await _saveLibraries();
  }

  Future<void> removeBookFromLibrary(String libraryId, Book book) async {
    state = state.map((lib) {
      if (lib.id == libraryId) {
        final updatedBooks = lib.books.where((b) => b.id != book.id).toList();
        return lib.copyWith(books: updatedBooks);
      }
      return lib;
    }).toList();
    await _saveLibraries();
  }
}

final libraryProvider = StateNotifierProvider<LibraryNotifier, List<Library>>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  return LibraryNotifier(prefs);
});
