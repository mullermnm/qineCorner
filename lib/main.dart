import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'core/providers/library_provider.dart';
import 'core/providers/favorite_provider.dart';
import 'core/router/app_router.dart';
import 'app.dart';

// Shared Preferences provider
final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError();
});

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize SharedPreferences
  final prefs = await SharedPreferences.getInstance();
  
  // Initialize router
  await AppRouter.initialize();

  // Create LibraryNotifier instance
  final libraryNotifier = LibraryNotifier(prefs);
  await libraryNotifier.loadInitialData(); // Load initial data
  
  runApp(
    ProviderScope(
      overrides: [
        // Override SharedPreferences provider
        sharedPreferencesProvider.overrideWithValue(prefs),
        // Override FavoriteProvider with initialized instance
        favoriteProvider.overrideWith((ref) => FavoriteNotifier(prefs)),
        // Override LibraryProvider with initialized instance
        libraryProvider.overrideWith((ref) => libraryNotifier),
      ],
      child: const App(),
    ),
  );
}
