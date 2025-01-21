import 'dart:convert';
import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:qine_corner/core/models/book_club.dart';
import 'package:qine_corner/core/models/reading_schedule.dart';
import 'package:qine_corner/core/models/user_with_role.dart';
import 'package:qine_corner/core/providers/auth_provider.dart';
import 'package:qine_corner/core/services/book_club_service.dart';
import 'package:qine_corner/core/api/api_service.dart';

final apiServiceProvider = Provider<ApiService>((ref) => ApiService());
final bookClubServiceProvider = Provider<BookClubService>(
    (ref) => BookClubService(ref.read(apiServiceProvider)));

final popularClubsProvider = FutureProvider<List<BookClub>>((ref) async {
  final service = ref.read(bookClubServiceProvider);
  return service.getPopularBookClubs();
});

final suggestedClubsProvider = FutureProvider<List<BookClub>>((ref) async {
  final service = ref.read(bookClubServiceProvider);
  return service.getSuggestedBookClubs();
});

final myClubsProvider = FutureProvider<List<BookClub>>((ref) async {
  final service = ref.read(bookClubServiceProvider);
  return service.getMyBookClubs();
});

final myAdminClubsProvider = FutureProvider<List<BookClub>>((ref) async {
  final service = ref.read(bookClubServiceProvider);
  return service.getMyAdminClubs();
});

final myMemberClubsProvider = FutureProvider<List<BookClub>>((ref) async {
  final service = ref.read(bookClubServiceProvider);
  return service.getMyMemberClubs();
});

final bookClubDetailsProvider =
    FutureProvider.family<BookClub, String>((ref, id) async {
  final service = ref.read(bookClubServiceProvider);
  return service.getBookClubDetails(id);
});

final bookClubMembersProvider = AsyncNotifierProvider.autoDispose<
    BookClubMembersNotifier, List<UserWithRole>>(
  () => BookClubMembersNotifier(),
);

class BookClubMembersNotifier
    extends AutoDisposeAsyncNotifier<List<UserWithRole>> {
  late final BookClubService _service;

  @override
  Future<List<UserWithRole>> build() async {
    _service = ref.read(bookClubServiceProvider);
    return [];
  }

  Future<void> getBookClubMembers(String clubId) async {
    try {
      final response = await _service.getBookClubMembers(clubId);
      state = AsyncValue.data(response.cast<UserWithRole>());
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }
}

class BookClubNotifier extends StateNotifier<AsyncValue<BookClub?>> {
  final BookClubService _service;

  BookClubNotifier(this._service) : super(const AsyncValue.data(null));

  Future<void> createBookClub({
    required String name,
    required String description,
    String? currentBook,
    required bool isPrivate,
    required List<String> genres,
    XFile? imageFile,
  }) async {
    try {
      state = const AsyncValue.loading();

      String? base64Image;
      if (imageFile != null) {
        final bytes = await imageFile.readAsBytes();
        base64Image = base64Encode(bytes);
      }

      final bookClub = await _service.createBookClub(
        name: name,
        description: description,
        isPrivate: isPrivate,
        genres: genres,
        imageBase64: base64Image,
      );

      state = AsyncValue.data(bookClub);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
      rethrow;
    }
  }

  Future<void> updateBookClub(
    String id, {
    String? name,
    String? description,
    String? currentBook,
    bool? isPrivate,
    List<String>? genres,
    XFile? imageFile,
  }) async {
    try {
      state = const AsyncValue.loading();

      String? base64Image;
      if (imageFile != null) {
        final bytes = await imageFile.readAsBytes();
        base64Image = base64Encode(bytes);
      }

      final bookClub = await _service.updateBookClub(
        id,
        name: name,
        description: description,
        currentBook: currentBook,
        isPrivate: isPrivate,
        genres: genres,
        imageBase64: base64Image,
      );

      state = AsyncValue.data(bookClub);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
      rethrow;
    }
  }

  Future<void> deleteBookClub(String id) async {
    try {
      state = const AsyncValue.loading();
      await _service.deleteBookClub(id);
      state = const AsyncValue.data(null);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
      rethrow;
    }
  }

  Future<void> joinBookClub(String clubId) async {
    try {
      state = const AsyncValue.loading();
      await _service.joinBookClub(clubId);
      state = const AsyncValue.data(null);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
      rethrow;
    }
  }

  Future<void> leaveBookClub(String clubId) async {
    try {
      state = const AsyncValue.loading();
      await _service.leaveBookClub(clubId);
      state = const AsyncValue.data(null);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
      rethrow;
    }
  }
}

final bookClubProvider =
    StateNotifierProvider<BookClubNotifier, AsyncValue<BookClub?>>((ref) {
  return BookClubNotifier(ref.read(bookClubServiceProvider));
});
