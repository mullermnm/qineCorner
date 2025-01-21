import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:qine_corner/core/models/reading_goal.dart';

class ReadingGoalNotifier extends StateNotifier<ReadingGoal?> {
  final SharedPreferences _prefs;
  static const String _goalKey = 'reading_goal';
  static const String _progressKey = 'reading_progress';
  static const String _lastUpdateKey = 'last_update';

  ReadingGoalNotifier(this._prefs) : super(null) {
    _loadGoal();
  }

  void _loadGoal() {
    final goalJson = _prefs.getString(_goalKey);
    if (goalJson != null) {
      try {
        final Map<String, dynamic> data = json.decode(goalJson);
        state = ReadingGoal.fromJson(data);
        print('Loaded goal: ${state?.dailyMinutes} minutes');
        _checkAndResetProgress();
      } catch (e) {
        print('Error loading goal: $e');
        _initializeGoal();
      }
    } else {
      _initializeGoal();
    }
  }

  void _initializeGoal() {
    state = ReadingGoal(
      dailyMinutes: 30,
      notificationTime: '20:00',
      notificationsEnabled: true,
    );
    _saveGoal();
  }

  Future<void> _saveGoal() async {
    if (state == null) return;

    try {
      final goalJson = json.encode(state!.toJson());
      await _prefs.setString(_goalKey, goalJson);
      print('Saved goal: ${state?.dailyMinutes} minutes');
    } catch (e) {
      print('Error saving goal: $e');
    }
  }

  bool hasGoal() {
    return state != null;
  }

  Future<void> saveGoal(ReadingGoal goal) async {
    state = goal;
    await _saveGoal();
    print('Saved new goal: ${goal.dailyMinutes} minutes');
  }

  Future<void> updateGoal(int minutes) async {
    if (minutes < 1) return;

    state = ReadingGoal(
      dailyMinutes: minutes,
      notificationTime: state?.notificationTime ?? '20:00',
      notificationsEnabled: state?.notificationsEnabled ?? true,
    );

    await _saveGoal();
    print('Updated goal to: $minutes minutes');
  }

  Future<void> _checkAndResetProgress() async {
    final lastUpdate = DateTime.fromMillisecondsSinceEpoch(
      _prefs.getInt(_lastUpdateKey) ?? 0,
    );
    final now = DateTime.now();

    if (lastUpdate.day != now.day ||
        lastUpdate.month != now.month ||
        lastUpdate.year != now.year) {
      await _prefs.setInt(_progressKey, 0);
      await _prefs.setInt(_lastUpdateKey, now.millisecondsSinceEpoch);
      print('Reset daily progress');
    }
  }

  Future<void> addReadingTime(int minutes) async {
    if (state == null) return;

    await _checkAndResetProgress();

    final currentProgress = _prefs.getInt(_progressKey) ?? 0;
    final newProgress = currentProgress + minutes;

    await _prefs.setInt(_progressKey, newProgress);
    await _prefs.setInt(_lastUpdateKey, DateTime.now().millisecondsSinceEpoch);

    print('Added $minutes minutes, total progress: $newProgress');
  }

  int getTodayProgress() {
    _checkAndResetProgress();
    return _prefs.getInt(_progressKey) ?? 0;
  }
}

final readingGoalProvider =
    StateNotifierProvider<ReadingGoalNotifier, ReadingGoal?>((ref) {
  return ReadingGoalNotifier(ref.watch(sharedPreferencesProvider));
});

final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError('Initialize in main.dart');
});
