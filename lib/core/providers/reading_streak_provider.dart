import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/reading_streak.dart';

class ReadingStreakNotifier extends StateNotifier<ReadingStreak?> {
  final SharedPreferences _prefs;
  static const String _streakKey = 'reading_streak';
  static const String _lastStreakKey = 'last_streak_update';

  ReadingStreakNotifier(this._prefs) : super(null) {
    _loadStreak();
  }

  Future<void> _loadStreak() async {
    final streakJson = _prefs.getString(_streakKey);
    if (streakJson != null) {
      try {
        final Map<String, dynamic> data = json.decode(streakJson);
        state = ReadingStreak.fromJson(data);
        debugPrint(
            '[ReadingStreakNotifier] Loaded streak: ${state?.currentStreak}, Last read: ${state?.lastReadDate}');
        await _checkAndUpdateStreak();
      } catch (e) {
        debugPrint('[ReadingStreakNotifier] Error loading streak: $e');
        _initializeStreak();
      }
    } else {
      _initializeStreak();
    }
  }

  void _initializeStreak() {
    state = ReadingStreak(
      currentStreak: 0,
      longestStreak: 0,
      lastReadDate: DateTime.now(),
      goalAchievedToday: false,
      achievements: [],
    );
    _saveStreak();
  }

  Future<void> _saveStreak() async {
    if (state == null) return;

    try {
      final streakJson = json.encode(state!.toJson());
      await _prefs.setString(_streakKey, streakJson);
      debugPrint(
          '[ReadingStreakNotifier] Saved streak: ${state?.currentStreak}, Goal achieved: ${state?.goalAchievedToday}');
    } catch (e) {
      debugPrint('[ReadingStreakNotifier] Error saving streak: $e');
    }
  }

  Future<void> recordReadingProgress(int minutesRead, int dailyGoal) async {
    if (state == null) return;

    final now = DateTime.now();
    final lastRead = state!.lastReadDate;

    debugPrint(
        '[ReadingStreakNotifier] Recording progress - Minutes: $minutesRead, Goal: $dailyGoal');
    debugPrint(
        '[ReadingStreakNotifier] Current streak: ${state!.currentStreak}, Goal achieved: ${state!.goalAchievedToday}');
    debugPrint('[ReadingStreakNotifier] Last read: ${state!.lastReadDate}');

    // Check if it's a new day
    bool isNewDay = lastRead.day != now.day ||
        lastRead.month != now.month ||
        lastRead.year != now.year;

    debugPrint('[ReadingStreakNotifier] Is new day: $isNewDay');

    // If goal is achieved for today
    if (minutesRead >= dailyGoal) {
      debugPrint('[ReadingStreakNotifier] Goal achieved! Updating streak...');
      
      // If goal wasn't previously achieved today, increment the streak immediately
      int newStreak = state!.currentStreak;
      if (!state!.goalAchievedToday) {
        newStreak += 1;
        debugPrint(
            '[ReadingStreakNotifier] Goal achieved for the first time today, incrementing streak to: $newStreak');
      }

      state = state!.copyWith(
        currentStreak: newStreak,
        longestStreak:
            newStreak > state!.longestStreak ? newStreak : state!.longestStreak,
        lastReadDate: now,
        goalAchievedToday: true,
      );

      await _saveStreak();
      debugPrint('[ReadingStreakNotifier] Streak updated successfully');
    } else {
      debugPrint('[ReadingStreakNotifier] No streak update needed');
      // Update last read date even if goal is not achieved
      state = state!.copyWith(lastReadDate: now);
      await _saveStreak();
    }
  }

  Future<void> _checkAndUpdateStreak() async {
    if (state == null) return;

    final now = DateTime.now();
    final lastRead = state!.lastReadDate;
    final difference = now.difference(lastRead).inDays;

    debugPrint(
        '[ReadingStreakNotifier] Checking streak... Last read: $lastRead, Difference: $difference days');

    // Reset streak if more than a day has passed without reading
    if (difference > 1) {
      debugPrint('[ReadingStreakNotifier] Resetting streak due to inactivity');
      state = state!.copyWith(
        currentStreak: 0,
        lastReadDate: now,
        goalAchievedToday: false,
      );
      await _saveStreak();
    } else if (now.day != lastRead.day ||
        now.month != lastRead.month ||
        now.year != lastRead.year) {
      // Reset goalAchievedToday flag for a new day
      debugPrint(
          '[ReadingStreakNotifier] New day detected, resetting goalAchievedToday');
      state = state!.copyWith(
        goalAchievedToday: false,
      );
      await _saveStreak();
    }
  }

  Future<void> incrementStreak() async {
    if (state == null) return;

    final now = DateTime.now();
    final lastStreakDate = DateTime.fromMillisecondsSinceEpoch(
      _prefs.getInt(_lastStreakKey) ?? 0,
    );

    // Check if we already updated the streak today
    if (lastStreakDate.year == now.year &&
        lastStreakDate.month == now.month &&
        lastStreakDate.day == now.day) {
      debugPrint('[ReadingStreakNotifier] Streak already updated today');
      return;
    }

    // Update streak
    state = state!.copyWith(
      currentStreak: state!.currentStreak + 1,
      lastReadDate: now,
    );

    // Save new streak
    await _saveStreak();
    await _prefs.setInt(_lastStreakKey, now.millisecondsSinceEpoch);

    debugPrint(
        '[ReadingStreakNotifier] Incremented streak to: ${state!.currentStreak}');
  }
}

final readingStreakProvider =
    StateNotifierProvider<ReadingStreakNotifier, ReadingStreak?>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  return ReadingStreakNotifier(prefs);
});

final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError();
});
