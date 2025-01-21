import 'dart:convert';

class ReadingGoal {
  final int dailyMinutes;
  final int todayMinutes;
  final int streakDays;
  final DateTime? lastReadDate;
  final bool notificationsEnabled;
  final String notificationTime;

  ReadingGoal({
    required this.dailyMinutes,
    this.todayMinutes = 0,
    this.streakDays = 0,
    this.lastReadDate,
    required this.notificationsEnabled,
    required this.notificationTime,
  });

  factory ReadingGoal.fromJson(Map<String, dynamic> json) {
    return ReadingGoal(
      dailyMinutes: json['dailyMinutes'],
      todayMinutes: json['todayMinutes'] ?? 0,
      streakDays: json['streakDays'] ?? 0,
      lastReadDate: json['lastReadDate'] != null
          ? DateTime.parse(json['lastReadDate'])
          : null,
      notificationsEnabled: json['notificationsEnabled'],
      notificationTime: json['notificationTime'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'dailyMinutes': dailyMinutes,
      'todayMinutes': todayMinutes,
      'streakDays': streakDays,
      'lastReadDate': lastReadDate?.toIso8601String(),
      'notificationsEnabled': notificationsEnabled,
      'notificationTime': notificationTime,
    };
  }

  ReadingGoal copyWith({
    int? dailyMinutes,
    int? todayMinutes,
    int? streakDays,
    DateTime? lastReadDate,
    bool? notificationsEnabled,
    String? notificationTime,
  }) {
    return ReadingGoal(
      dailyMinutes: dailyMinutes ?? this.dailyMinutes,
      todayMinutes: todayMinutes ?? this.todayMinutes,
      streakDays: streakDays ?? this.streakDays,
      lastReadDate: lastReadDate ?? this.lastReadDate,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      notificationTime: notificationTime ?? this.notificationTime,
    );
  }
}
