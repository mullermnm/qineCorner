import '../models/book.dart';
import '../api/api_service.dart';
import '../api/api_config.dart';

class SearchService {
  final ApiService _apiService;

  SearchService(this._apiService);

  Future<List<Book>> searchBooks({
    required String query,
    int page = 1,
    int pageSize = 20,
  }) async {
    try {
      final response = await _apiService.get(
        '${ApiConfig.books}/search',
        queryParams: {
          'query': query,
          'page': page.toString(),
          'pageSize': pageSize.toString(),
        },
      );
      final data = ApiConfig.extractData(response);
      return (data as List).map((json) => Book.fromJson(json)).toList();
    } catch (e) {
      print('Error searching books: $e');
      return [];
    }
  }

  Future<List<Book>> getPopularBooks({int page = 1, int pageSize = 20}) async {
    try {
      final response = await _apiService.get(
        ApiConfig.books,
        queryParams: {
          'page': page.toString(),
          'pageSize': pageSize.toString(),
          'sort': 'popular',
        },
      );

      final data = ApiConfig.extractData(response);
      if (data == null) return [];

      List<dynamic> booksList;
      if (data is Map && data.containsKey('books')) {
        booksList = data['books'] as List;
      } else if (data is List) {
        booksList = data;
      } else {
        return [];
      }

      return booksList.map((json) {
        try {
          if (json is Map<String, dynamic>) {
            return Book.fromJson(json);
          } else if (json is Map) {
            return Book.fromJson(Map<String, dynamic>.from(json));
          }
        } catch (e) {
          print('Error parsing individual book: $e');
          print('Problematic book data: $json');
        }
        return null;
      }).whereType<Book>().toList();

    } catch (e, stack) {
      print('Error fetching popular books: $e');
      print('Stack trace: $stack');
      return [];
    }
  }

  Future<List<Book>> getBooksByCategory(String categoryId,
      {int page = 1, int pageSize = 20}) async {
    try {
      final response = await _apiService.get(
        ApiConfig.booksByCategory(categoryId),
        queryParams: {
          'page': page.toString(),
          'pageSize': pageSize.toString(),
        },
      );
      final data = ApiConfig.extractData(response);
      
      // Handle both List and Map responses
      if (data is List) {
        return data.map((json) => Book.fromJson(json)).toList();
      } else if (data is Map<String, dynamic>) {
        // Try to extract books from the map
        if (data.containsKey('books') && data['books'] is List) {
          return (data['books'] as List).map((json) => Book.fromJson(json)).toList();
        } else {
          // If no 'books' key, try to convert the whole map to a list of books
          List<Book> books = [];
          data.forEach((key, value) {
            if (value is Map<String, dynamic>) {
              try {
                books.add(Book.fromJson(value));
              } catch (e) {
                print('Error parsing book from map entry: $e');
              }
            }
          });
          return books;
        }
      }
      
      // Fallback to empty list if data is neither List nor Map
      return [];
    } catch (e) {
      print('Error fetching books by category: $e');
      return [];
    }
  }

  Future<List<Book>> getBooksByAuthor(String authorId,
      {String? excludeBookId, int page = 1, int pageSize = 20}) async {
    try {
      final response = await _apiService.get(
        ApiConfig.booksByAuthor(authorId),
        queryParams: {
          'page': page.toString(),
          'pageSize': pageSize.toString(),
          if (excludeBookId != null) 'exclude': excludeBookId,
        },
      );
      final data = ApiConfig.extractData(response);
      if (data == null) return [];

      List<dynamic> booksList;
      if (data is Map && data.containsKey('books')) {
        booksList = data['books'] as List;
      } else if (data is List) {
        booksList = data;
      } else {
        return [];
      }

      return booksList.map((json) {
        try {
          if (json is Map<String, dynamic>) {
            return Book.fromJson(json);
          } else if (json is Map) {
            return Book.fromJson(Map<dynamic, dynamic>.from(json));
          }
        } catch (e) {
          print('Error parsing individual book: $e');
          print('Problematic book data: $json');
        }
        return null;
      }).whereType<Book>().toList();

    } catch (e, stack) {
      print('Error fetching recent books: $e');
      print('Stack trace: $stack');
      return [];
    }
  }

  Future<List<Book>> getRecentBooks({int page = 1, int pageSize = 20}) async {
    try {
      final response = await _apiService.get(
        ApiConfig.books,
        queryParams: {
          'page': page.toString(),
          'pageSize': pageSize.toString(),
          'sort': 'recent',
        },
      );

      final data = ApiConfig.extractData(response);
      if (data == null) return [];

      List<dynamic> booksList;
      if (data is Map && data.containsKey('books')) {
        booksList = data['books'] as List;
      } else if (data is List) {
        booksList = data;
      } else {
        return [];
      }

      return booksList.map((json) {
        try {
          if (json is Map<String, dynamic>) {
            return Book.fromJson(json);
          } else if (json is Map) {
            return Book.fromJson(Map<dynamic, dynamic>.from(json));
          }
        } catch (e) {
          print('Error parsing individual book: $e');
          print('Problematic book data: $json');
        }
        return null;
      }).whereType<Book>().toList();

    } catch (e, stack) {
      print('Error fetching recent books: $e');
      print('Stack trace: $stack');
      return [];
    }
  }

  Future<List<Book>> getBooksByYear(int year,
      {int page = 1, int pageSize = 20}) async {
    try {
      final queryParams = {
        'year': year.toString(),
        'page': page.toString(),
        'pageSize': pageSize.toString(),
      };
      final response = await _apiService.get(
        ApiConfig.books,
        queryParams: queryParams,
      );
      final data = ApiConfig.extractData(response);
      return (data as List).map((json) => Book.fromJson(json)).toList();
    } catch (e) {
      print('Error fetching books by year: $e');
      return [];
    }
  }

  Future<void> updateBookProgress(String bookId, DateTime lastRead) async {
    try {
      await _apiService.post(
        ApiConfig.bookProgress(bookId),
        body: {'lastRead': lastRead.toIso8601String()},
      );
    } catch (e) {
      print('Error updating book progress: $e');
      rethrow;
    }
  }
}
