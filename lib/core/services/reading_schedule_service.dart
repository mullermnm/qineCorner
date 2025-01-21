import 'package:qine_corner/core/api/api_service.dart';
import 'package:qine_corner/core/models/reading_schedule.dart';

class ReadingScheduleService {
  final ApiService _apiService;

  ReadingScheduleService(this._apiService);

  Future<List<ReadingSchedule>> getSchedules(String bookClubId) async {
    try {
      final response = await _apiService.get('/book-clubs/$bookClubId/schedules');
      print('Schedule response: $response');

      if (response['data'] is Map && response['data']['data'] is List) {
        final scheduleList = response['data']['data'] as List;
        return scheduleList.map((json) => ReadingSchedule.fromJson(json)).toList();
      } else if (response['data'] is List) {
        final scheduleList = response['data'] as List;
        return scheduleList.map((json) => ReadingSchedule.fromJson(json)).toList();
      }
      
      return [];
    } catch (e) {
      print('Error getting schedules: $e');
      rethrow;
    }
  }

  Future<ReadingSchedule> createSchedule(
    String bookClubId, {
    required DateTime startDate,
    required DateTime endDate,
    required List<String> chapters,
    String? notes,
  }) async {
    try {
      final response = await _apiService.post(
        '/book-clubs/$bookClubId/schedules',
        body: {
          'start_date': startDate.toIso8601String(),
          'end_date': endDate.toIso8601String(),
          'chapters': chapters,
          if (notes != null) 'notes': notes,
        },
      );

      return ReadingSchedule.fromJson(response['data']);
    } catch (e) {
      print('Error creating schedule: $e');
      rethrow;
    }
  }

  Future<ReadingSchedule> updateSchedule(
    String bookClubId,
    int scheduleId, {
    DateTime? startDate,
    DateTime? endDate,
    List<String>? chapters,
    String? notes,
  }) async {
    try {
      final response = await _apiService.put(
        '/book-clubs/$bookClubId/schedules/$scheduleId',
        body: {
          if (startDate != null) 'start_date': startDate.toIso8601String(),
          if (endDate != null) 'end_date': endDate.toIso8601String(),
          if (chapters != null) 'chapters': chapters,
          if (notes != null) 'notes': notes,
        },
      );

      return ReadingSchedule.fromJson(response['data']);
    } catch (e) {
      print('Error updating schedule: $e');
      rethrow;
    }
  }

  Future<void> deleteSchedule(String bookClubId, int scheduleId) async {
    try {
      await _apiService.delete('/book-clubs/$bookClubId/schedules/$scheduleId');
    } catch (e) {
      print('Error deleting schedule: $e');
      rethrow;
    }
  }
}
