import 'package:qine_corner/core/api/api_service.dart';
import 'package:qine_corner/core/models/book_club.dart';
import 'package:qine_corner/core/models/reading_schedule.dart';

class BookClubService {
  final ApiService _apiService;

  BookClubService(this._apiService);

  Future<List<BookClub>> getBookClubs({
    String? search,
    String? genre,
    String? order,
  }) async {
    final queryParams = {
      if (search != null) 'search': search,
      if (genre != null) 'genre': genre,
      if (order != null) 'order': order,
    };

    final response =
        await _apiService.get('/book-clubs', queryParams: queryParams);
    return (response['data'] as List)
        .map((json) => BookClub.fromJson(json))
        .toList();
  }

  Future<BookClub> createBookClub({
    required String name,
    required String description,
    required List<String> genres,
    String? imageBase64,
    bool isPrivate = false,
  }) async {
    try {
      final response = await _apiService.post(
        '/book-clubs',
        body: {
          'name': name,
          'description': description,
          'genres': genres,
          'imageBase64': imageBase64,
          'is_private': isPrivate,
        },
      );
      return BookClub.fromJson(response['data'] as Map<String, dynamic>);
    } catch (e) {
      print('Error creating book club: $e');
      rethrow;
    }
  }

  Future<BookClub> getBookClubDetails(String id) async {
    final response = await _apiService.get('/book-clubs/$id');
    return BookClub.fromJson(response['data']);
  }

  Future<List<Map<String, dynamic>>> getBookClubMembers(String clubId) async {
    final response = await _apiService.get('/book-clubs/$clubId/members');
    return List<Map<String, dynamic>>.from(response['data']);
  }

  Future<BookClub> joinBookClub(String clubId) async {
    try {
      final response = await _apiService.post('/book-clubs/$clubId/join');
      return BookClub.fromJson(response['data'] as Map<String, dynamic>);
    } catch (e) {
      print('Error joining book club: $e');
      rethrow;
    }
  }

  Future<bool> isClubMember(String clubId) async {
    try {
      final response = await _apiService.get('/book-clubs/$clubId/is-member');
      return response['data']['is_member'] as bool;
    } catch (e) {
      print('Error checking club membership: $e');
      return false;
    }
  }

  Future<void> leaveBookClub(String clubId) async {
    await _apiService.post('/book-clubs/$clubId/leave');
  }

  Future<List<BookClub>> getPopularBookClubs() async {
    final response = await _apiService.get('/book-clubs/popular');
    return (response['data'] as List)
        .map((json) => BookClub.fromJson(json))
        .toList();
  }

  Future<List<BookClub>> getSuggestedBookClubs() async {
    final response = await _apiService.get('/book-clubs/suggested');
    return (response['data'] as List)
        .map((json) => BookClub.fromJson(json))
        .toList();
  }

  Future<List<BookClub>> getMyBookClubs() async {
    final response = await _apiService.get('/book-clubs/my-clubs');
    return (response['data'] as List)
        .map((json) => BookClub.fromJson(json))
        .toList();
  }

  Future<List<BookClub>> getMyAdminClubs() async {
    try {
      final response = await _apiService.get('/book-clubs/list/owned');
      return (response['data'] as List)
          .map((json) => BookClub.fromJson(json))
          .toList();
    } catch (e) {
      print('Error getting admin clubs: $e');
      rethrow;
    }
  }

  Future<List<BookClub>> getMyMemberClubs() async {
    try {
      final response = await _apiService.get('/book-clubs/list/memberships');
      return (response['data'] as List)
          .map((json) => BookClub.fromJson(json))
          .toList();
    } catch (e) {
      print('Error getting member clubs: $e');
      return [];
    }
  }

  Future<BookClub> updateBookClub(
    String id, {
    String? name,
    String? description,
    String? currentBook,
    bool? isPrivate,
    List<String>? genres,
    String? imageBase64,
  }) async {
    final body = {
      if (name != null) 'name': name,
      if (description != null) 'description': description,
      if (currentBook != null) 'currentBook': currentBook,
      if (isPrivate != null) 'isPrivate': isPrivate,
      if (genres != null) 'genres': genres,
      if (imageBase64 != null) 'image': imageBase64,
    };

    final response = await _apiService.put('/book-clubs/$id', body: body);
    return BookClub.fromJson(response['data']);
  }

  Future<void> deleteBookClub(String id) async {
    await _apiService.delete('/book-clubs/$id');
  }
}
