import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qine_corner/features/articles_leaderboard/models/leaderboard_article.dart';

// State class for the leaderboard
class LeaderboardState {
  final bool isLoading;
  final List<LeaderboardArticle> articles;
  final String? errorMessage;

  const LeaderboardState({
    this.isLoading = false,
    this.articles = const [],
    this.errorMessage,
  });

  LeaderboardState copyWith({
    bool? isLoading,
    List<LeaderboardArticle>? articles,
    String? errorMessage,
  }) {
    return LeaderboardState(
      isLoading: isLoading ?? this.isLoading,
      articles: articles ?? this.articles,
      errorMessage: errorMessage,
    );
  }

  // Helper getters for UI
  List<LeaderboardArticle> get topThreeArticles => 
      articles.where((article) => article.rank <= 3).toList();
  
  List<LeaderboardArticle> get remainingArticles => 
      articles.where((article) => article.rank > 3 && article.rank <= 10).toList();
}

// Notifier class for the leaderboard
class LeaderboardNotifier extends StateNotifier<LeaderboardState> {
  LeaderboardNotifier() : super(const LeaderboardState()) {
    // Load data when initialized
    fetchLeaderboardArticles();
  }

  Future<void> fetchLeaderboardArticles() async {
    try {
      state = state.copyWith(isLoading: true, errorMessage: null);
      
      // TODO: Replace with actual API call
      await Future.delayed(const Duration(seconds: 1));
      
      // Mock data for now
      final articles = _getMockArticles();
      
      state = state.copyWith(
        isLoading: false,
        articles: articles,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Failed to load leaderboard: $e',
      );
    }
  }

  // Mock data for development
  List<LeaderboardArticle> _getMockArticles() {
    return [
      LeaderboardArticle(
        id: 1,
        title: 'The Power of Daily Reading',
        author: 'Abebe Kebede',
        likeCount: 342,
        commentCount: 56,
        coverImage: 'assets/images/article1.jpg',
        rank: 1,
      ),
      LeaderboardArticle(
        id: 2,
        title: 'How to Build a Reading Habit',
        author: 'Sara Mohammed',
        likeCount: 287,
        commentCount: 42,
        coverImage: 'assets/images/article2.jpg',
        rank: 2,
      ),
      LeaderboardArticle(
        id: 3,
        title: 'Best Books of 2024',
        author: 'Daniel Tesfaye',
        likeCount: 253,
        commentCount: 38,
        coverImage: 'assets/images/article3.jpg',
        rank: 3,
      ),
      LeaderboardArticle(
        id: 4,
        title: 'Reading for Personal Growth',
        author: 'Hiwot Alemu',
        likeCount: 198,
        commentCount: 29,
        coverImage: 'assets/images/article4.jpg',
        rank: 4,
      ),
      LeaderboardArticle(
        id: 5,
        title: 'The Science Behind Reading Comprehension',
        author: 'Yonas Girma',
        likeCount: 176,
        commentCount: 24,
        coverImage: 'assets/images/article5.jpg',
        rank: 5,
      ),
      LeaderboardArticle(
        id: 6,
        title: 'Digital vs. Physical Books',
        author: 'Tigist Haile',
        likeCount: 154,
        commentCount: 31,
        coverImage: 'assets/images/article6.jpg',
        rank: 6,
      ),
      LeaderboardArticle(
        id: 7,
        title: 'Reading with Children',
        author: 'Dawit Mengistu',
        likeCount: 132,
        commentCount: 27,
        coverImage: 'assets/images/article7.jpg',
        rank: 7,
      ),
      LeaderboardArticle(
        id: 8,
        title: 'Book Clubs and Community Reading',
        author: 'Meron Tadesse',
        likeCount: 118,
        commentCount: 19,
        coverImage: 'assets/images/article8.jpg',
        rank: 8,
      ),
      LeaderboardArticle(
        id: 9,
        title: 'Speed Reading Techniques',
        author: 'Solomon Bekele',
        likeCount: 103,
        commentCount: 15,
        coverImage: 'assets/images/article9.jpg',
        rank: 9,
      ),
      LeaderboardArticle(
        id: 10,
        title: 'Reading in the Digital Age',
        author: 'Rahel Negash',
        likeCount: 97,
        commentCount: 12,
        coverImage: 'assets/images/article10.jpg',
        rank: 10,
      ),
    ];
  }
}

// Provider for the leaderboard
final leaderboardProvider = StateNotifierProvider<LeaderboardNotifier, LeaderboardState>((ref) {
  return LeaderboardNotifier();
});
