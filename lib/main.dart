import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:qine_corner/app.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:qine_corner/core/providers/shared_preferences_provider.dart';
import 'package:qine_corner/core/api/api_service.dart';
import 'package:qine_corner/core/providers/books_provider.dart';
import 'package:qine_corner/core/providers/favorite_provider.dart';
import 'package:qine_corner/core/providers/library_provider.dart'
    as libraryProvider;
import 'package:qine_corner/core/providers/reading_goal_provider.dart'
    as readingGoalProvider;
import 'package:qine_corner/core/providers/reading_streak_provider.dart'
    as streakProvider;
import 'package:qine_corner/core/providers/auth_provider.dart';
import 'package:qine_corner/core/router/app_router.dart';
import 'package:qine_corner/core/services/search_service.dart';
import 'package:qine_corner/core/theme/theme_provider.dart' as themeProvider;
import 'package:qine_corner/core/services/book_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize SharedPreferences
  final prefs = await SharedPreferences.getInstance();

  // Create services
  final searchService = SearchService(ApiService());
  final bookService = BookService(ApiService());

  // Create notifier instances
  final libraryNotifier = libraryProvider.LibraryNotifier(prefs);
  await libraryNotifier.loadInitialData();
  final readingGoalNotifier = readingGoalProvider.ReadingGoalNotifier(prefs);
  final readingStreakNotifier = streakProvider.ReadingStreakNotifier(prefs);
  final booksNotifier = BooksNotifier(searchService, bookService);
  final themeNotifier = themeProvider.ThemeNotifier();
  final favoriteNotifier = FavoriteNotifier(prefs);

  runApp(
    ProviderScope(
      overrides: [
        // Override SharedPreferences provider
        sharedPreferencesProvider.overrideWithValue(prefs),
        // Override providers with initialized instances
        favoriteProvider.overrideWith((ref) => favoriteNotifier),
        libraryProvider.libraryProvider.overrideWith((ref) => libraryNotifier),
        readingGoalProvider.readingGoalProvider
            .overrideWith((ref) => readingGoalNotifier),
        streakProvider.readingStreakProvider
            .overrideWith((ref) => readingStreakNotifier),
        booksProvider.overrideWith((ref) => booksNotifier),
        themeProvider.themeProvider.overrideWith((ref) => themeNotifier),
        // Auth provider doesn't need initialization as it starts with loading state
      ],
      child: const App(),
    ),
  );
}
