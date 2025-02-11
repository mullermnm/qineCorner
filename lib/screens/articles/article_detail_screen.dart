import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:qine_corner/common/widgets/loading_animation.dart';
import 'package:qine_corner/core/models/article.dart';
import 'package:qine_corner/core/providers/article_provider.dart';
import 'package:qine_corner/core/providers/auth_provider.dart';
import 'package:qine_corner/screens/error/widgets/animated_error_widget.dart';

class ArticleDetailScreen extends ConsumerStatefulWidget {
  final String articleId;

  const ArticleDetailScreen({
    super.key,
    required this.articleId,
  });

  @override
  ConsumerState<ArticleDetailScreen> createState() =>
      _ArticleDetailScreenState();
}

class _ArticleDetailScreenState extends ConsumerState<ArticleDetailScreen> {
  @override
  Widget build(BuildContext context) {
    final articleAsync = ref.watch(articleDetailsProvider(widget.articleId));
    final currentUser = ref.watch(authNotifierProvider).value?.user;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Article Details'),
        actions: articleAsync.when(
          data: (article) {
            if (article == null) return [];
            if (currentUser?.id != article.author.id) return [];

            return [
              PopupMenuButton<String>(
                onSelected: (value) async {
                  if (value == 'delete') {
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text('Delete Article'),
                        content: const Text(
                          'Are you sure you want to delete this article?',
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text('Cancel'),
                          ),
                          TextButton(
                            onPressed: () async {
                              await ref
                                  .read(articleProvider.notifier)
                                  .deleteArticle(widget.articleId);
                              if (context.mounted) {
                                context.pop();
                                context.pop();
                              }
                            },
                            child: const Text('Delete'),
                          ),
                        ],
                      ),
                    );
                  } else if (value == 'publish' &&
                      article.status == ArticleStatus.draft) {
                    await ref
                        .read(articleProvider.notifier)
                        .publishArticle(article.id.toString());
                  } else if (value == 'unpublish' &&
                      article.status == ArticleStatus.published) {
                    await ref
                        .read(articleProvider.notifier)
                        .moveToDraft(article.id.toString());
                  }
                },
                itemBuilder: (context) => [
                  if (article.status == ArticleStatus.draft)
                    const PopupMenuItem(
                      value: 'publish',
                      child: Text('Publish'),
                    )
                  else if (article.status == ArticleStatus.published)
                    const PopupMenuItem(
                      value: 'unpublish',
                      child: Text('Move to Draft'),
                    ),
                  const PopupMenuItem(
                    value: 'delete',
                    child: Text('Delete'),
                  ),
                ],
              ),
            ];
          },
          loading: () => [],
          error: (_, __) => [],
        ),
      ),
      body: articleAsync.when(
        data: (article) {
          if (article == null) {
            return const Center(
              child: Text('Article not found'),
            );
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (article.media.isNotEmpty)
                  AspectRatio(
                    aspectRatio: 16 / 9,
                    child: Image.network(
                      article.media.first.url,
                      fit: BoxFit.cover,
                    ),
                  ),
                const SizedBox(height: 16),
                Text(
                  article.title,
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    CircleAvatar(
                      backgroundImage: article.author.profileImage != null
                          ? NetworkImage(article.author.profileImage!)
                          : null,
                      child: article.author.profileImage == null
                          ? Text(article.author.name[0])
                          : null,
                    ),
                    const SizedBox(width: 8),
                    Text(article.author.name),
                  ],
                ),
                const SizedBox(height: 16),
                Text(article.content),
                const SizedBox(height: 16),
                Wrap(
                  spacing: 8,
                  children: article.tags
                      .map(
                        (tag) => Chip(
                          label: Text(tag),
                        ),
                      )
                      .toList(),
                ),
              ],
            ),
          );
        },
        loading: () => const LoadingAnimation(),
        error: (error, stackTrace) => AnimatedErrorWidget(
          message: error.toString(),
          onRetry: () => ref.refresh(articleDetailsProvider(widget.articleId)),
        ),
      ),
    );
  }
}
