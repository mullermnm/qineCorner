import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qine_corner/core/api/api_service.dart';
import 'package:qine_corner/core/models/reading_schedule.dart';
import 'package:qine_corner/core/services/reading_schedule_service.dart';

final readingScheduleServiceProvider = Provider<ReadingScheduleService>(
  (ref) => ReadingScheduleService(ref.read(apiServiceProvider)),
);

// Provider for fetching schedules for a book club
final readingSchedulesProvider = FutureProvider.autoDispose
    .family<List<ReadingSchedule>, String>((ref, clubId) async {
  final service = ref.read(readingScheduleServiceProvider);
  return service.getSchedules(clubId);
});

// Provider for managing a single schedule
final readingScheduleProvider = StateNotifierProvider.family<
    ReadingScheduleNotifier,
    AsyncValue<ReadingSchedule?>,
    String>((ref, scheduleId) {
  return ReadingScheduleNotifier(ref.read(readingScheduleServiceProvider), ref);
});

class ReadingScheduleNotifier
    extends StateNotifier<AsyncValue<ReadingSchedule?>> {
  final ReadingScheduleService _service;
  final Ref _ref;

  ReadingScheduleNotifier(this._service, this._ref)
      : super(const AsyncValue.data(null));

  Future<void> createSchedule(
    String bookClubId, {
    required DateTime startDate,
    required DateTime endDate,
    required List<String> chapters,
    String? notes,
  }) async {
    try {
      state = const AsyncValue.loading();
      final schedule = await _service.createSchedule(
        bookClubId,
        startDate: startDate,
        endDate: endDate,
        chapters: chapters,
        notes: notes ?? '',
      );
      state = AsyncValue.data(schedule);
      // Invalidate the schedules list to trigger a refresh
      _ref.invalidate(readingSchedulesProvider(bookClubId));
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
      rethrow;
    }
  }

  Future<void> updateSchedule(
    String bookClubId,
    int scheduleId, {
    DateTime? startDate,
    DateTime? endDate,
    List<String>? chapters,
    String? notes,
  }) async {
    try {
      state = const AsyncValue.loading();
      final schedule = await _service.updateSchedule(
        bookClubId,
        scheduleId,
        startDate: startDate,
        endDate: endDate,
        chapters: chapters,
        notes: notes,
      );
      state = AsyncValue.data(schedule);
      // Invalidate the schedules list to trigger a refresh
      _ref.invalidate(readingSchedulesProvider(bookClubId));
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
      rethrow;
    }
  }

  Future<void> deleteSchedule(String bookClubId, int scheduleId) async {
    try {
      state = const AsyncValue.loading();
      await _service.deleteSchedule(bookClubId, scheduleId);
      state = const AsyncValue.data(null);
      // Invalidate the schedules list to trigger a refresh
      _ref.invalidate(readingSchedulesProvider(bookClubId));
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
      rethrow;
    }
  }
}
