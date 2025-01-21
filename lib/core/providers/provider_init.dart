import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Import reading goal and streak providers with aliases
import 'reading_goal_provider.dart' as goalProvider;
import 'reading_streak_provider.dart' as streakProvider;

Future<ProviderContainer> initializeProviders() async {
  final container = ProviderContainer(
    overrides: [
      goalProvider.sharedPreferencesProvider.overrideWithValue(
        await SharedPreferences.getInstance(),
      ),
    ],
  );

  // Initialize providers
  container.read(goalProvider.readingGoalProvider);
  container.read(streakProvider.readingStreakProvider);

  return container;
}
