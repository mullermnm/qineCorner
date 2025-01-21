class ReadingStreak {
  final int currentStreak;
  final int longestStreak;
  final DateTime lastReadDate;
  final bool goalAchievedToday;
  final List<String> achievements;

  ReadingStreak({
    required this.currentStreak,
    required this.longestStreak,
    required this.lastReadDate,
    required this.goalAchievedToday,
    this.achievements = const [],
  });

  factory ReadingStreak.initial() => ReadingStreak(
        currentStreak: 0,
        longestStreak: 0,
        lastReadDate: DateTime.now(),
        goalAchievedToday: false,
      );

  ReadingStreak copyWith({
    int? currentStreak,
    int? longestStreak,
    DateTime? lastReadDate,
    bool? goalAchievedToday,
    List<String>? achievements,
  }) {
    return ReadingStreak(
      currentStreak: currentStreak ?? this.currentStreak,
      longestStreak: longestStreak ?? this.longestStreak,
      lastReadDate: lastReadDate ?? this.lastReadDate,
      goalAchievedToday: goalAchievedToday ?? this.goalAchievedToday,
      achievements: achievements ?? this.achievements,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'currentStreak': currentStreak,
      'longestStreak': longestStreak,
      'lastReadDate': lastReadDate.toIso8601String(),
      'goalAchievedToday': goalAchievedToday,
      'achievements': achievements,
    };
  }

  factory ReadingStreak.fromJson(Map<String, dynamic> json) {
    return ReadingStreak(
      currentStreak: json['currentStreak'] as int,
      longestStreak: json['longestStreak'] as int,
      lastReadDate: DateTime.parse(json['lastReadDate'] as String),
      goalAchievedToday: json['goalAchievedToday'] as bool,
      achievements: (json['achievements'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
    );
  }
}
