import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qine_corner/core/models/book.dart';
import 'package:qine_corner/core/providers/library_provider.dart';
import 'package:qine_corner/core/providers/auth_provider.dart';
import 'package:qine_corner/core/providers/reading_goal_provider.dart';
import 'package:qine_corner/screens/articles/articles_screen.dart';
import 'package:qine_corner/screens/articles/create_article_screen.dart';
import 'package:qine_corner/screens/auth/forgot_password_screen.dart';
import 'package:qine_corner/screens/auth/verify_otp_screen.dart';
import 'package:qine_corner/screens/book/book_detail_screen.dart';
import 'package:qine_corner/screens/book/book_request_screen.dart';
import 'package:qine_corner/screens/book_club/book_club_details_screen.dart';
import 'package:qine_corner/screens/book_club/book_club_screen.dart';
import 'package:qine_corner/screens/book_club/create_book_club_screen.dart';
import 'package:qine_corner/screens/book_club/create_discussion_screen.dart';
import 'package:qine_corner/screens/book_club/create_schedule_screen.dart';
import 'package:qine_corner/screens/book_club/my_clubs_screen.dart';
import 'package:qine_corner/screens/common/error_screen.dart';
import 'package:qine_corner/screens/error/widgets/animated_error_widget.dart';
import 'package:qine_corner/screens/goal/goal_setup_screen.dart';
import 'package:qine_corner/screens/library/libraries_screen.dart';
import 'package:qine_corner/screens/library/library_detail_screen.dart';
import 'package:qine_corner/screens/notes/notes_overview_screen.dart';
import 'package:qine_corner/screens/profile/profile_screen.dart';
import 'package:qine_corner/screens/profile/edit_profile_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../screens/home/home_screen.dart';
import '../../screens/onboarding/onboarding_screen.dart';
import '../../screens/downloads/downloads_screen.dart';
import '../../screens/settings/settings_screen.dart';
import '../../screens/settings/reading_preferences_screen.dart';
import '../../screens/book/favorites_screen.dart';
import '../../screens/auth/login_screen.dart';
import '../../screens/auth/register_screen.dart';
import '../../screens/auth/verification_screen.dart';
import '../../common/widgets/bottom_navigation/custom_buttom_navigation.dart';

class AppRouter {
  static final _rootNavigatorKey =
      GlobalKey<NavigatorState>(debugLabel: 'root');
  static final _shellNavigatorKey =
      GlobalKey<NavigatorState>(debugLabel: 'shell');

  static late final GoRouter router;

  static Future<void> initialize(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    final isFirstTime = prefs.getBool('first_time') ?? true;
    final hasReadingGoal = prefs.getString('reading_goal') != null;

    router = GoRouter(
      navigatorKey: _rootNavigatorKey,
      initialLocation: isFirstTime
          ? '/onboarding'
          : hasReadingGoal
              ? '/home'
              : '/goal-setup',
      routes: [
        GoRoute(
          path: '/onboarding',
          builder: (context, state) => const OnboardingScreen(),
        ),
        GoRoute(
          path: '/goal-setup',
          builder: (context, state) =>
              const GoalSetupScreen(isOnboarding: true),
        ),
        GoRoute(
          path: '/login',
          builder: (context, state) => const LoginScreen(),
        ),
        GoRoute(
          path: '/register',
          builder: (context, state) => const RegisterScreen(),
        ),
        GoRoute(
          path: '/forgot-password',
          builder: (context, state) => const ForgotPasswordScreen(),
        ),
        GoRoute(
          path: '/verify-otp',
          builder: (context, state) {
            final extra = state.extra as Map<String, dynamic>?;
            return VerifyOtpScreen(
              phoneNumber: extra?['phoneNumber'] as String? ?? '',
              onVerificationComplete: extra?['onVerificationComplete'],
            );
          },
        ),
        ShellRoute(
          navigatorKey: _shellNavigatorKey,
          builder: (context, state, child) {
            return Consumer(
              builder: (context, ref, _) {
                final authState = ref.watch(authNotifierProvider);
                return authState.when(
                  data: (authState) {
                    // Check if current route requires authentication
                    final currentPath = state.uri.toString();
                    final requiresAuth = [
                      '/book-request',
                      '/profile',
                      '/book-clubs/create',
                      '/book-clubs/my-clubs',
                      '/book-clubs/:id/discussions/create',
                      'book-clubs/:id/schedules/create',
                      '/articles/create',
                    ].any((path) => currentPath.startsWith(path));

                    if (authState == null) {
                      if (requiresAuth) {
                        return const LoginScreen();
                      }
                      return ScaffoldWithBottomNavBar(child: child);
                    }

                    if (requiresAuth && !authState.token.isNotEmpty) {
                      return const LoginScreen();
                    }

                    if (authState.token.isNotEmpty &&
                        !authState.isVerified &&
                        currentPath != '/verify-otp') {
                      return VerificationScreen(
                        userId: authState.userId ?? '',
                        phone: authState.phone ?? '',
                      );
                    }

                    return ScaffoldWithBottomNavBar(child: child);
                  },
                  loading: () => const Scaffold(
                    body: Center(child: CircularProgressIndicator()),
                  ),
                  error: (error, _) => Scaffold(
                    body: Center(
                      child: AnimatedErrorWidget(
                        message: error.toString(),
                        onRetry: () => GoRouter.of(context).go('/home'),
                      ),
                    ),
                  ),
                );
              },
            );
          },
          routes: [
            GoRoute(
              path: '/home',
              builder: (context, state) => const HomeScreen(),
            ),
            GoRoute(
              path: '/',
              builder: (context, state) => const HomeScreen(),
            ),
            GoRoute(
              path: '/profile',
              builder: (context, state) => const ProfileScreen(),
            ),
            GoRoute(
              path: '/profile/edit',
              builder: (context, state) => const EditProfileScreen(),
            ),
            GoRoute(
              path: '/reading-preferences',
              builder: (context, state) => const ReadingPreferencesScreen(),
            ),
            GoRoute(
              path: '/downloads',
              builder: (context, state) => const DownloadsScreen(),
            ),
            GoRoute(
              path: '/goal-setup',
              builder: (context, state) => const GoalSetupScreen(),
            ),
            GoRoute(
              path: '/libraries',
              builder: (context, state) => const LibrariesScreen(),
            ),
            GoRoute(
              path: '/library/:id',
              builder: (context, state) {
                final libraryId = state.pathParameters['id'];
                if (libraryId == null) {
                  return const ErrorScreen(error: 'Library ID not found');
                }

                final container = ProviderScope.containerOf(context);
                final libraries = container.read(libraryProvider);
                final library = libraries.firstWhere(
                  (lib) => lib.id == libraryId,
                  orElse: () => throw Exception('Library not found'),
                );
                return LibraryDetailScreen(library: library);
              },
            ),
            GoRoute(
              path: '/settings',
              builder: (context, state) => const SettingsScreen(),
            ),
            GoRoute(
              path: '/daily-goal',
              builder: (context, state) =>
                  const GoalSetupScreen(isOnboarding: false),
            ),
            GoRoute(
              path: '/favorites',
              builder: (context, state) => const FavoritesScreen(),
            ),
            GoRoute(
              path: '/notes',
              builder: (context, state) => const NotesOverviewScreen(),
            ),
            GoRoute(
              path: '/book-request',
              builder: (context, state) => BookRequestScreen(
                initialTitle: state.extra as String?,
              ),
            ),
            GoRoute(
              path: '/book/:id',
              builder: (context, state) {
                final id = state.pathParameters['id'];
                if (id == null) {
                  return const ErrorScreen(error: 'Book ID not found');
                }
                final book = state.extra as Book?;
                if (book == null) {
                  return const ErrorScreen(error: 'Book data not found');
                }
                return BookDetailScreen(book: book);
              },
            ),
            GoRoute(
              path: '/book-clubs',
              builder: (context, state) => const BookClubScreen(),
            ),
            GoRoute(
              path: '/book-clubs/create',
              builder: (context, state) => const CreateBookClubScreen(),
            ),
            GoRoute(
              path: '/book-clubs/my-clubs',
              builder: (context, state) => const MyClubsScreen(),
            ),
            GoRoute(
              path: '/book-clubs/:id',
              builder: (context, state) {
                final id = state.pathParameters['id']!;
                return BookClubDetailsScreen(clubId: id);
              },
            ),
            GoRoute(
              path: '/book-clubs/:id/discussions/create',
              builder: (context, state) {
                final id = state.pathParameters['id']!;
                return CreateDiscussionScreen(bookClubId: id);
              },
            ),
            GoRoute(
              path: '/book-clubs/:id/schedules/create',
              builder: (context, state) {
                final id = state.pathParameters['id']!;
                return CreateScheduleScreen(bookClubId: id);
              },
            ),
            GoRoute(
              path: '/articles',
              builder: (context, state) => const ArticlesScreen(),
            ),
            GoRoute(
              path: '/articles/create',
              builder: (context, state) => const CreateArticleScreen(),
            ),
          ],
        ),
      ],
      redirect: (context, state) async {
        final prefs = await SharedPreferences.getInstance();
        final isFirstTime = prefs.getBool('first_time') ?? true;
        final container = ProviderScope.containerOf(context);
        final hasGoal = container.read(readingGoalProvider) != null;
        final authState = container.read(authNotifierProvider);

        final isLoggedIn = authState.when(
          data: (state) => state != null && state.token.isNotEmpty,
          loading: () => false,
          error: (_, __) => false,
        );

        final isGoingToAuth = state.matchedLocation.startsWith('/login') ||
            state.matchedLocation.startsWith('/register') ||
            state.matchedLocation.startsWith('/forgot-password') ||
            state.matchedLocation.startsWith('/verify');

        if (isFirstTime) {
          return '/onboarding';
        }

        if (!hasGoal && !isGoingToAuth) {
          return '/goal-setup';
        }

        // Check if route requires authentication
        final requiresAuth = [
          '/book-request',
          '/book-clubs/create',
          '/book-clubs/my-clubs',
          '/articles/create',
        ].any((path) => state.matchedLocation.startsWith(path));

        if (requiresAuth && !isLoggedIn && !isGoingToAuth) {
          return '/login';
        }

        return null;
      },
    );
  }
}
