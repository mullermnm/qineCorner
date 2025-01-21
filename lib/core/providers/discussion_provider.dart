import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qine_corner/core/api/api_service.dart';
import 'package:qine_corner/core/models/discussion.dart';
import 'package:qine_corner/core/services/discussion_service.dart';

final discussionServiceProvider = Provider<DiscussionService>(
  (ref) => DiscussionService(ref.read(apiServiceProvider)),
);

// Provider for fetching discussions for a book club
final discussionsProvider = FutureProvider.autoDispose
    .family<List<Discussion>, String>((ref, clubId) async {
  final service = ref.read(discussionServiceProvider);
  return service.getDiscussions(clubId);
});

// Provider for managing a single discussion
final discussionProvider = StateNotifierProvider.family<DiscussionNotifier,
    AsyncValue<Discussion?>, String>((ref, discussionId) {
  return DiscussionNotifier(ref.read(discussionServiceProvider), ref);
});

class DiscussionNotifier extends StateNotifier<AsyncValue<Discussion?>> {
  final DiscussionService _service;
  final Ref _ref;

  DiscussionNotifier(this._service, this._ref)
      : super(const AsyncValue.data(null));

  Future<void> createDiscussion(
      String bookClubId, String title, String content) async {
    try {
      state = const AsyncValue.loading();
      final discussion =
          await _service.createDiscussion(bookClubId, title, content);
      state = AsyncValue.data(discussion);
      // Invalidate the discussions list to trigger a refresh
      _ref.invalidate(discussionsProvider(bookClubId));
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
      throw error; // Re-throw to handle in UI
    }
  }

  Future<void> updateDiscussion(String bookClubId, String discussionId,
      String title, String content) async {
    try {
      state = const AsyncValue.loading();
      final discussion = await _service.updateDiscussion(
          bookClubId, discussionId, title, content);
      state = AsyncValue.data(discussion);
      // Invalidate the discussions list to trigger a refresh
      _ref.invalidate(discussionsProvider(bookClubId));
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
      throw error;
    }
  }

  Future<void> deleteDiscussion(String bookClubId, String discussionId) async {
    try {
      state = const AsyncValue.loading();
      await _service.deleteDiscussion(bookClubId, discussionId);
      state = const AsyncValue.data(null);
      // Invalidate the discussions list to trigger a refresh
      _ref.invalidate(discussionsProvider(bookClubId));
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
      throw error;
    }
  }
}
