import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qine_corner/core/models/article.dart';
import 'package:qine_corner/core/services/article_service.dart';
import 'package:qine_corner/core/providers/api_provider.dart';

final articleServiceProvider = Provider<ArticleService>((ref) {
  final apiService = ref.watch(apiServiceProvider);
  return ArticleService(apiService);
});

final featuredArticlesProvider = FutureProvider<List<Article>>((ref) async {
  final articleService = ref.watch(articleServiceProvider);
  return articleService.getFeaturedArticles();
});

final articlesProvider = FutureProvider.family<List<Article>, ArticleFilter>(
  (ref, filter) async {
    final articleService = ref.watch(articleServiceProvider);
    return articleService.getArticles(
      category: filter.category,
      query: filter.query,
      page: filter.page,
      limit: filter.limit,
    );
  },
);

final articleDetailsProvider =
    FutureProvider.family<Article, String>((ref, articleId) async {
  final articleService = ref.watch(articleServiceProvider);
  return articleService.getArticleDetails(articleId);
});

class ArticleFilter {
  final String? category;
  final String? query;
  final int page;
  final int limit;

  const ArticleFilter({
    this.category,
    this.query,
    this.page = 1,
    this.limit = 10,
  });

  ArticleFilter copyWith({
    String? category,
    String? query,
    int? page,
    int? limit,
  }) {
    return ArticleFilter(
      category: category ?? this.category,
      query: query ?? this.query,
      page: page ?? this.page,
      limit: limit ?? this.limit,
    );
  }
}
