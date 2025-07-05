import 'package:go_router/go_router.dart';
import 'package:qine_corner/features/articles_leaderboard/screens/articles_leaderboard_screen.dart';

// Define routes for the leaderboard feature
List<RouteBase> leaderboardRoutes = [
  GoRoute(
    path: 'leaderboard',
    builder: (context, state) => const ArticlesLeaderboardScreen(),
  ),
  // Add more routes as needed, such as article detail routes
];
