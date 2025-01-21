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

      if (data is Map && data.containsKey('books')) {
        final List booksList = data['books'] as List;
        return booksList.map((json) {
          if (json is Map) {
            final Map<String, dynamic> bookJson = Map<String, dynamic>.from(json);
            bookJson['id'] = json['id'].toString();
            if (json['author'] != null && json['author']['id'] != null) {
              final authorJson = Map<String, dynamic>.from(json['author'] as Map);
              authorJson['id'] = authorJson['id'].toString();
              bookJson['author'] = authorJson;
            }
            if (json['categories'] != null) {
              bookJson['categories'] = (json['categories'] as List).map((cat) {
                if (cat is Map) {
                  final categoryJson = Map<String, dynamic>.from(cat);
                  categoryJson['id'] = categoryJson['id'].toString();
                  return categoryJson['id'];
                }
                return cat.toString();
              }).toList();
            }
            return Book.fromJson(bookJson);
          }
          return null;
        }).whereType<Book>().toList();
      }

      return [];
    } catch (e) {
      print('Error fetching popular books: $e');
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
      return (data as List).map((json) => Book.fromJson(json)).toList();
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
      return (data as List).map((json) => Book.fromJson(json)).toList();
    } catch (e) {
      print('Error fetching books by author: $e');
      return [];
    }
  }

  Future<List<Book>> getRecentBooks({int page = 1, int pageSize = 20}) async {
    try {
      final response = await _apiService.get(
        '${ApiConfig.books}/recent',
        queryParams: {
          'page': page.toString(),
          'pageSize': pageSize.toString(),
        },
      );

      print('Recent Books Response: $response');
      final data = ApiConfig.extractData(response);
      print('Extracted Data: $data');

      if (data == null) {
        print('No data extracted');
        return [];
      }

      if (data is Map && data.containsKey('books')) {
        final List booksList = data['books'] as List;
        print('Books list length: ${booksList.length}');
        final books = booksList
            .map((json) {
              if (json is Map) {
                final Map<String, dynamic> bookJson = Map<String, dynamic>.from(json);
                bookJson['id'] = json['id'].toString();
                
                // Handle author
                if (json['author'] != null && json['author']['id'] != null) {
                  final authorJson = Map<String, dynamic>.from(json['author'] as Map);
                  authorJson['id'] = authorJson['id'].toString();
                  bookJson['author'] = authorJson;
                }
                
                // Handle categories - extract just the IDs
                if (json['categories'] != null) {
                  final categoriesList = json['categories'] as List;
                  final categoryIds = categoriesList.map((cat) {
                    if (cat is Map) {
                      return cat['id'].toString();
                    }
                    return cat.toString();
                  }).toList();
                  bookJson['categories'] = categoryIds;
                } else {
                  bookJson['categories'] = <String>[];
                }
                
                // Handle optional fields
                bookJson['rating'] = json['rating'] ?? 0.0;
                bookJson['cover_url'] = json['cover_url'] ?? '';
                bookJson['file_path'] = json['file_path'] ?? '';
                bookJson['published_at'] = json['published_at'] ?? DateTime.now().toIso8601String();
                
                try {
                  print('Creating book from JSON: $bookJson');
                  final book = Book.fromJson(bookJson);
                  print('Successfully created book: ${book.title} with ${book.categories.length} categories');
                  return book;
                } catch (e, stack) {
                  print('Error creating Book from JSON: $e');
                  print('Stack trace: $stack');
                  print('JSON data: $bookJson');
                  return null;
                }
              }
              return null;
            })
            .whereType<Book>()
            .toList();

        print('Converted books length: ${books.length}');
        return books;
      }

      print('No books found in data');
      return [];
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
