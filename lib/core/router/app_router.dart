import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qine_corner/core/providers/library_provider.dart';
import 'package:qine_corner/screens/error/widgets/animated_error_widget.dart';
import 'package:qine_corner/screens/library/libraries_screen.dart';
import 'package:qine_corner/screens/library/library_detail_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../screens/home/home_screen.dart';
import '../../screens/onboarding/onboarding_screen.dart';
import '../../screens/downloads/downloads_screen.dart';
import '../../screens/settings/settings_screen.dart';
import '../../screens/book/favorites_screen.dart';
import '../../common/widgets/bottom_navigation/custom_buttom_navigation.dart';

class AppRouter {
  static final _rootNavigatorKey =
      GlobalKey<NavigatorState>(debugLabel: 'root');
  static final _shellNavigatorKey =
      GlobalKey<NavigatorState>(debugLabel: 'shell');

  static late final GoRouter router;

  static Future<void> initialize() async {
    final prefs = await SharedPreferences.getInstance();
    final isFirstTime = prefs.getBool('first_time') ?? true;

    router = GoRouter(
      navigatorKey: _rootNavigatorKey,
      initialLocation: isFirstTime ? '/onboarding' : '/home',
      routes: [
        GoRoute(
          path: '/onboarding',
          builder: (context, state) => const OnboardingScreen(),
        ),
        ShellRoute(
          navigatorKey: _shellNavigatorKey,
          builder: (context, state, child) {
            return ScaffoldWithBottomNavBar(child: child);
          },
          routes: [
            GoRoute(
              path: '/home',
              builder: (context, state) => const HomeScreen(),
            ),
            GoRoute(
              path: '/downloads',
              builder: (context, state) => const DownloadsScreen(),
            ),
            GoRoute(
              path: '/libraries',
              builder: (context, state) => const LibrariesScreen(),
            ),
            GoRoute(
              path: '/library/:id',
              builder: (context, state) {
                final libraryId = state.pathParameters['id']!;
                final container = ProviderScope.containerOf(context);
                final libraries = container.read(libraryProvider);
                final library = libraries.firstWhere(
                  (lib) => lib.id == libraryId,
                  orElse: () => throw Exception('Library not found'),
                );

                if (library == null) {
                  return Scaffold(
                    body: Center(
                      child: AnimatedErrorWidget(
                        message: 'Library not found',
                        onRetry: () => GoRouter.of(context).go('/libraries'),
                      ),
                    ),
                  );
                }

                return LibraryDetailScreen(library: library);
              },
            ),
            GoRoute(
              path: '/settings',
              builder: (context, state) => const SettingsScreen(),
            ),
            GoRoute(
              path: '/favorites',
              builder: (context, state) => const FavoritesScreen(),
            ),
          ],
        ),
      ],
      redirect: (context, state) async {
        final prefs = await SharedPreferences.getInstance();
        final isFirstTime = prefs.getBool('first_time') ?? true;

        // If not first time and trying to access onboarding, redirect to home
        if (!isFirstTime && state.uri.path == '/onboarding') {
          return '/home';
        }

        // Allow all other routes
        return null;
      },
    );
  }
}
