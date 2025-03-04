import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:qine_corner/core/api/api_config.dart';
import 'package:qine_corner/core/api/api_service.dart';

class BookService {
  final ApiService _apiService;
  
  BookService(this._apiService);

  Future<Map<dynamic, dynamic>> uploadBook({
    required String title,
    required String author,
    required String category,
    required String description,
    required DateTime published_at,
    required String coverImagePath,
    required String bookFilePath,
  }) async {
    try {
      return await _apiService.postMultipart(
        '${ApiConfig.books}/add',
        fields: {
          'title': title,
          'author_id': author,
          'categories': category,
          'published_at': published_at.toIso8601String(),
          'description': description,
        },
        files: {
          'cover_image': coverImagePath,
          'bookFile': bookFilePath,
        },
      );
    } catch (e) {
      throw Exception('Error uploading book: $e');
    }
  }
}
      
