import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qine_corner/core/api/api_service.dart';
import 'package:qine_corner/core/models/author.dart';
import '../services/author_service.dart';

class AuthorsNotifier extends StateNotifier<AsyncValue<List<Author>>> {
  final AuthorService _authorService;

  AuthorsNotifier(this._authorService) : super(const AsyncValue.loading()) {
    getAllAuthors();
  }

  Future<void> getAllAuthors() async {
    try {
      final authors = await _authorService.getAllAuthors();
      state = AsyncValue.data(authors);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}

final authorsProvider =
    StateNotifierProvider<AuthorsNotifier, AsyncValue<List<Author>>>(
        (ref) {
  final apiService = ref.read(apiServiceProvider);
  final authorService = AuthorService(apiService);
  return AuthorsNotifier(authorService);
});

class AuthorsProvider with ChangeNotifier {
  final AuthorService _authorService;
  List<Author> _authors = [];
  bool _isLoading = false;
  String? _error;

  AuthorsProvider({required AuthorService authorService})
      : _authorService = authorService;

  List<Author> get authors => _authors;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> fetchAuthors() async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      _authors = await _authorService.getAllAuthors();
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<Map<String, dynamic>> addAuthor({
    required String name,
    String? biography,
    String? photoPath,
    String? birthDate,
  }) async {
    try {
      final newAuthor = await _authorService.uploadAuthor(
        name: name,
        biography: biography,
        photoPath: photoPath,
        birthDate: birthDate,
      );
      
      await fetchAuthors(); // Refresh the authors list
      return newAuthor;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      throw e;
    }
  }

  Future<Author?> getAuthorById(String authorId) async {
    try {
      return await _authorService.getAuthorById(authorId);
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      throw e;
    }
  }

  // Future<void> updateAuthor({
  //   required String authorId,
  //   required String name,
  //   String? biography,
  //   String? photoUrl,
  // }) async {
  //   try {
  //     await _authorService.updateAuthor(
  //       authorId: authorId,
  //       name: name,
  //       biography: biography,
  //       photoUrl: photoUrl,
  //     );
      
  //     await fetchAuthors(); // Refresh the authors list
  //   } catch (e) {
  //     _error = e.toString();
  //     notifyListeners();
  //     throw e;
  //   }
  // }

  // Future<void> deleteAuthor(String authorId) async {
  //   try {
  //     await _authorService.deleteAuthor(authorId);
  //     await fetchAuthors(); // Refresh the authors list
  //   } catch (e) {
  //     _error = e.toString();
  //     notifyListeners();
  //     throw e;
  //   }
  // }
} 