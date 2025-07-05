import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:qine_corner/features/articles_leaderboard/models/leaderboard_article.dart';
import 'package:qine_corner/features/articles_leaderboard/providers/leaderboard_provider.dart';
import 'package:qine_corner/features/articles_leaderboard/widgets/podium_article_card.dart';
import 'package:qine_corner/features/articles_leaderboard/widgets/leaderboard_list_item.dart';

class ArticlesLeaderboardScreen extends ConsumerStatefulWidget {
  const ArticlesLeaderboardScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<ArticlesLeaderboardScreen> createState() =>
      _ArticlesLeaderboardScreenState();
}

class _ArticlesLeaderboardScreenState
    extends ConsumerState<ArticlesLeaderboardScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
      ),
    );

    _slideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.2), end: Offset.zero).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
      ),
    );

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _navigateToArticleDetails(LeaderboardArticle article) {
    // Navigate to article details using GoRouter
    context.push('/article/${article.id}');
  }

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    final isDark = brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Top Articles'),
        centerTitle: true,
        elevation: 0,
      ),
      body: Consumer(
        builder: (context, ref, _) {
          final state = ref.watch(leaderboardProvider);

          return RefreshIndicator(
            onRefresh: () async {
              ref.read(leaderboardProvider.notifier).fetchLeaderboardArticles();
            },
            child: _buildContent(state),
          );
        },
      ),
    );
  }

  Widget _buildContent(LeaderboardState state) {
    if (state.isLoading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text(
              'Loading top articles...',
              style: TextStyle(fontStyle: FontStyle.italic),
            ),
          ],
        ),
      );
    }

    if (state.errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 48, color: Colors.red),
            const SizedBox(height: 16),
            Text(
              'Something went wrong',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(
              state.errorMessage!,
              style: Theme.of(context).textTheme.bodySmall,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => ref
                  .read(leaderboardProvider.notifier)
                  .fetchLeaderboardArticles(),
              child: const Text('Try Again'),
            ),
          ],
        ),
      );
    }

    if (state.articles.isEmpty) {
      return const Center(
        child: Text('No articles found'),
      );
    }

    return _buildLeaderboardContent(state.articles);
  }

  Widget _buildLeaderboardContent(List<LeaderboardArticle> articles) {
    final topThree = articles.where((article) => article.rank <= 3).toList();
    final remaining = articles
        .where((article) => article.rank > 3 && article.rank <= 10)
        .toList();

    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Podium section with animation
          FadeTransition(
            opacity: _fadeAnimation,
            child: SlideTransition(
              position: _slideAnimation,
              child: _buildPodium(topThree),
            ),
          ),

          // Divider
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Divider(thickness: 1.5),
          ),

          // Remaining articles
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Text(
              'More Top Articles',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
          ),

          // List of remaining articles with staggered animation
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: remaining.length,
            itemBuilder: (context, index) {
              final article = remaining[index];
              // Staggered animation for list items
              final delay = Duration(milliseconds: 100 * index);

              return FutureBuilder(
                future: Future.delayed(delay),
                builder: (context, snapshot) {
                  return AnimatedOpacity(
                    opacity: snapshot.connectionState == ConnectionState.done
                        ? 1.0
                        : 0.0,
                    duration: const Duration(milliseconds: 300),
                    child: AnimatedSlide(
                      offset: snapshot.connectionState == ConnectionState.done
                          ? Offset.zero
                          : const Offset(0.0, 0.1),
                      duration: const Duration(milliseconds: 300),
                      child: LeaderboardListItem(
                        article: article,
                        onTap: () => _navigateToArticleDetails(article),
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildPodium(List<LeaderboardArticle> topArticles) {
    // Sort articles by rank to ensure correct order
    topArticles.sort((a, b) => a.rank.compareTo(b.rank));

    // Ensure we have exactly 3 articles for the podium
    while (topArticles.length < 3) {
      topArticles.add(LeaderboardArticle(
        id: -1 * (topArticles.length + 1), // Negative ID for placeholder
        title: 'Coming Soon',
        author: '',
        likeCount: 0,
        commentCount: 0,
        coverImage: '',
        rank: topArticles.length + 1,
      ));
    }

    // Extract articles by rank
    final firstPlace = topArticles.firstWhere((article) => article.rank == 1,
        orElse: () => topArticles[0]);
    final secondPlace = topArticles.firstWhere((article) => article.rank == 2,
        orElse: () => topArticles.length > 1 ? topArticles[1] : topArticles[0]);
    final thirdPlace = topArticles.firstWhere((article) => article.rank == 3,
        orElse: () => topArticles.length > 2 ? topArticles[2] : topArticles[0]);

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          // Title
          Text(
            'Top Articles Leaderboard',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),

          // Podium layout
          SizedBox(
            height: 280,
            child: Stack(
              alignment: Alignment.bottomCenter,
              children: [
                // Second place (left)
                Positioned(
                  left: 0,
                  bottom: 20,
                  child: SizedBox(
                    width: MediaQuery.of(context).size.width * 0.28,
                    child: Column(
                      children: [
                        PodiumArticleCard(
                          article: secondPlace,
                          onViewDetails: () =>
                              _navigateToArticleDetails(secondPlace),
                        ),
                        Container(
                          height: 60,
                          decoration: BoxDecoration(
                            color: Colors.grey[300],
                            borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(8),
                              topRight: Radius.circular(8),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // First place (center)
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 0,
                  child: Center(
                    child: SizedBox(
                      width: MediaQuery.of(context).size.width * 0.32,
                      child: Column(
                        children: [
                          PodiumArticleCard(
                            article: firstPlace,
                            onViewDetails: () =>
                                _navigateToArticleDetails(firstPlace),
                          ),
                          Container(
                            height: 80,
                            decoration: BoxDecoration(
                              color: Colors.amber[300],
                              borderRadius: const BorderRadius.only(
                                topLeft: Radius.circular(8),
                                topRight: Radius.circular(8),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                // Third place (right)
                Positioned(
                  right: 0,
                  bottom: 40,
                  child: SizedBox(
                    width: MediaQuery.of(context).size.width * 0.28,
                    child: Column(
                      children: [
                        PodiumArticleCard(
                          article: thirdPlace,
                          onViewDetails: () =>
                              _navigateToArticleDetails(thirdPlace),
                        ),
                        Container(
                          height: 40,
                          decoration: BoxDecoration(
                            color: Colors.brown[300],
                            borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(8),
                              topRight: Radius.circular(8),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
