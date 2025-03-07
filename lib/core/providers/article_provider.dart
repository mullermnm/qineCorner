import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:qine_corner/core/api/api_service.dart';
import 'package:qine_corner/core/models/article.dart';
import 'package:qine_corner/core/models/comment.dart';
import 'package:qine_corner/core/models/user.dart';
import 'package:qine_corner/core/providers/auth_provider.dart';
import 'package:qine_corner/core/services/article_service.dart';

class ArticleFilter {
  final String? category;
  final String? authorId;
  final ArticleStatus? status;

  const ArticleFilter({
    this.category,
    this.authorId,
    this.status,
  });

  bool matches(Article article) {
    if (category != null && !article.tags.contains(category)) {
      return false;
    }
    if (authorId != null && article.author.id != authorId) {
      return false;
    }
    if (status != null && article.status != status) {
      return false;
    }
    return true;
  }
}

final articleServiceProvider = Provider<ArticleService>((ref) {
  final apiService = ref.watch(apiServiceProvider);
  return ArticleService(apiService);
});

// List providers
final articlesProvider = FutureProvider<List<Article>>((ref) async {
  final service = ref.read(articleServiceProvider);
  return service.getArticles();
});

final filteredArticlesProvider =
    Provider.family<AsyncValue<List<Article>>, ArticleFilter>((ref, filter) {
  final articlesAsync = ref.watch(articlesProvider);
  return articlesAsync.whenData(
    (articles) => articles.where(filter.matches).toList(),
  );
});

final featuredArticlesProvider = FutureProvider<List<Article>>((ref) async {
  final service = ref.read(articleServiceProvider);
  return service.getFeaturedArticles();
});

final myArticlesProvider = FutureProvider<List<Article>>((ref) async {
  final service = ref.read(articleServiceProvider);
  final authState = ref.read(authNotifierProvider);
  final state = authState.when(
    data: (state) => state,
    loading: () => null,
    error: (_, __) => null,
  );
  if (state == null) return [];
  return service.getArticles(
    authorId: state.userId,
    status: ArticleStatus.published.name,
  );
});

final myDraftsProvider = FutureProvider<List<Article>>((ref) async {
  final service = ref.read(articleServiceProvider);
  final authState = ref.read(authNotifierProvider);
  final state = authState.when(
    data: (state) => state,
    loading: () => null,
    error: (_, __) => null,
  );
  if (state == null) return [];
  return service.getArticles(
    authorId: state.userId,
    status: ArticleStatus.draft.name,
  );
});

// Single article provider
final articleDetailsProvider =
    FutureProvider.family<Article?, String>((ref, id) async {
  final service = ref.read(articleServiceProvider);
  return service.getArticleDetails(id);
});

// Article state notifier
class ArticleNotifier extends StateNotifier<AsyncValue<Article?>> {
  final ArticleService _service;
  final User? _currentUser;

  ArticleNotifier(this._service, this._currentUser)
      : super(const AsyncValue.data(null));

  Future<void> createArticle({
    required String title,
    required String content,
    required List<String> tags,
    XFile? imageFile,
    bool isDraft = true,
  }) async {
    if (_currentUser == null) throw Exception('User must be logged in');

    try {
      state = const AsyncValue.loading();
      List<ArticleMedia> media = [];

      if (imageFile != null) {
        final imageUrl = await _service.uploadMedia(File(imageFile.path));
        media.add(ArticleMedia(
          id: 0, // Temporary ID
          url: imageUrl,
          type: 'image',
        ));
      }

      final article = Article(
        id: 0,
        title: title,
        content: content,
        author: _currentUser!,
        tags: tags,
        media: media,
        status: isDraft ? ArticleStatus.draft : ArticleStatus.published,
        views: 0,
        likes: 0,
        comments: 0,
        shares: 0,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final createdArticle = await _service.createArticle(article);
      state = AsyncValue.data(createdArticle);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  Future<void> updateArticle(
    String id, {
    String? title,
    String? content,
    List<String>? tags,
    XFile? imageFile,
    ArticleStatus? status,
  }) async {
    try {
      state = const AsyncValue.loading();

      final currentArticle = await _service.getArticleDetails(id);
      if (currentArticle == null) throw Exception('Article not found');

      List<ArticleMedia> media = List.from(currentArticle.media);

      if (imageFile != null) {
        final imageUrl = await _service.uploadMedia(File(imageFile.path));
        media.add(ArticleMedia(
          id: currentArticle.media.last.id, // Temporary ID
          url: imageUrl,
          type: 'image',
        ));
      }

      final updatedArticle = Article(
        id: currentArticle.id,
        title: title ?? currentArticle.title,
        content: content ?? currentArticle.content,
        author: currentArticle.author,
        tags: tags ?? currentArticle.tags,
        media: media,
        status: status ?? currentArticle.status,
        views: currentArticle.views,
        likes: currentArticle.likes,
        comments: currentArticle.comments,
        shares: currentArticle.shares,
        createdAt: currentArticle.createdAt,
        updatedAt: DateTime.now(),
      );

      final result = await _service.updateArticle(id, updatedArticle);
      state = AsyncValue.data(result);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  Future<void> deleteArticle(String id) async {
    try {
      state = const AsyncValue.loading();
      await _service.deleteArticle(id);
      state = const AsyncValue.data(null);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  Future<void> publishArticle(String id) async {
    try {
      state = const AsyncValue.loading();
      await _service.publishDraft(id);
      final article = await _service.getArticleDetails(id);
      state = AsyncValue.data(article);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  Future<void> moveToDraft(String id) async {
    try {
      state = const AsyncValue.loading();
      await _service.moveToDraft(id);
      final article = await _service.getArticleDetails(id);
      state = AsyncValue.data(article);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  Future<void> likeArticle(String id) async {
    try {
      await _service.likeArticle(id);
      // Refresh article details
      state = const AsyncValue.loading();
      final article = await _service.getArticleDetails(id);
      state = AsyncValue.data(article);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> unlikeArticle(String id) async {
    try {
      await _service.unlikeArticle(id);
      // Refresh article details
      state = const AsyncValue.loading();
      final article = await _service.getArticleDetails(id);
      state = AsyncValue.data(article);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}

final articleProvider =
    StateNotifierProvider<ArticleNotifier, AsyncValue<Article?>>((ref) {
  final authState = ref.read(authNotifierProvider);
  final state = authState.when(
    data: (state) => state,
    loading: () => null,
    error: (_, __) => null,
  );
  return ArticleNotifier(
    ref.read(articleServiceProvider),
    state?.user,
  );
});

// Add these providers
final articleCommentsProvider = FutureProvider.family<List<Comment>, String>(
  (ref, articleId) async {
    final service = ref.read(articleServiceProvider);
    return service.getComments(articleId);
  },
);
