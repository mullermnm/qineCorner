import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/book.dart';
import '../services/search_service.dart';
import '../api/api_service.dart';

final apiServiceProvider = Provider((ref) => ApiService());

final searchServiceProvider =
    Provider((ref) => SearchService(ref.read(apiServiceProvider)));

class BooksState {
  final AsyncValue<List<Book>> books;
  final List<Book> searchResults;

  const BooksState({
    required this.books,
    this.searchResults = const [],
  });

  BooksState copyWith({
    AsyncValue<List<Book>>? books,
    List<Book>? searchResults,
  }) {
    return BooksState(
      books: books ?? this.books,
      searchResults: searchResults ?? this.searchResults,
    );
  }
}

final booksProvider = StateNotifierProvider<BooksNotifier, BooksState>((ref) {
  final searchService = ref.read(searchServiceProvider);
  return BooksNotifier(searchService);
});

class BooksNotifier extends StateNotifier<BooksState> {
  final SearchService _searchService;
  String? _currentCategory;
  int _currentPage = 1;
  bool _hasMoreData = true;
  static const int _itemsPerPage = 20;

  BooksNotifier(this._searchService)
      : super(const BooksState(books: AsyncValue.data([]))) {
    loadInitialBooks();
  }

  Future<void> loadInitialBooks() async {
    state = state.copyWith(books: const AsyncValue.loading());

    try {
      final books = await _searchService.getPopularBooks(
        page: _currentPage,
        pageSize: _itemsPerPage,
      );
      state = state.copyWith(books: AsyncValue.data(books));
    } catch (e, st) {
      state = state.copyWith(books: AsyncValue.error(e, st));
    }
  }

  Future<void> loadMoreBooks() async {
    if (state.books is AsyncLoading || !_hasMoreData) return;

    try {
      final currentBooks = state.books.value ?? [];
      _currentPage++;

      final newBooks = _currentCategory == null
          ? await _searchService.getPopularBooks(
              page: _currentPage,
              pageSize: _itemsPerPage,
            )
          : await _searchService.getBooksByCategory(
              _currentCategory!,
              page: _currentPage,
              pageSize: _itemsPerPage,
            );

      if (newBooks.isEmpty) {
        _hasMoreData = false;
        return;
      }

      state = state.copyWith(
        books: AsyncValue.data([...currentBooks, ...newBooks]),
      );
    } catch (e, st) {
      _currentPage--;
      state = state.copyWith(books: AsyncValue.error(e, st));
    }
  }

  Future<void> filterByCategory(String? category) async {
    if (_currentCategory == category) return;

    state = state.copyWith(books: const AsyncValue.loading());
    _currentPage = 1;
    _hasMoreData = true;

    try {
      final books = await _searchService.getBooksByCategory(
        category ?? 'popular',
        page: _currentPage,
        pageSize: _itemsPerPage,
      );
      _currentCategory = category;
      state = state.copyWith(books: AsyncValue.data(books));
    } catch (e, st) {
      state = state.copyWith(books: AsyncValue.error(e, st));
    }
  }

  List<Book> getSearchResults() => state.searchResults;

  void searchBooks(String query) {
    if (query.isEmpty) {
      state = state.copyWith(searchResults: []);
      return;
    }

    final books = state.books.value ?? [];
    final lowercaseQuery = query.toLowerCase();
    final results = books.where((book) {
      final titleMatch = book.title.toLowerCase().contains(lowercaseQuery);
      final authorMatch = book.author.name.toLowerCase().contains(lowercaseQuery);
      final categoryMatch = book.categories
          .any((category) => category.toLowerCase().contains(lowercaseQuery));
      final descriptionMatch =
          book.description.toLowerCase().contains(lowercaseQuery);
      return titleMatch || authorMatch || categoryMatch || descriptionMatch;
    }).toList();

    state = state.copyWith(searchResults: results);
  }

  Future<void> refresh() async {
    _currentCategory = null;
    _currentPage = 1;
    _hasMoreData = true;
    await loadInitialBooks();
  }
}

// Additional providers for specific book lists
final recentBooksProvider = FutureProvider<List<Book>>((ref) async {
  print('Fetching recent books from provider');
  final searchService = ref.read(searchServiceProvider);
  final books = await searchService.getRecentBooks();
  print('Recent books fetched in provider: ${books.length}');
  return books;
});

final popularBooksProvider = FutureProvider<List<Book>>((ref) async {
  print('Fetching popular books from provider');
  final searchService = ref.read(searchServiceProvider);
  final books = await searchService.getPopularBooks();
  print('Popular books fetched in provider: ${books.length}');
  return books;
});
