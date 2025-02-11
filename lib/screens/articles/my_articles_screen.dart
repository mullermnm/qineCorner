import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:qine_corner/core/models/article.dart';
import 'package:qine_corner/core/providers/article_provider.dart';
import 'package:qine_corner/screens/articles/widgets/article_card.dart';

class MyArticlesScreen extends ConsumerWidget {
  const MyArticlesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final publishedArticles = ref.watch(myArticlesProvider);
    final draftArticles = ref.watch(myDraftsProvider);

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('My Articles'),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Published'),
              Tab(text: 'Drafts'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            // Published Articles Tab
            publishedArticles.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, stack) => Center(
                child: Text('Error: ${error.toString()}'),
              ),
              data: (articles) => _ArticlesList(
                articles: articles,
                emptyMessage: 'You haven\'t published any articles yet',
                actionButton: ElevatedButton(
                  onPressed: () => context.push('/articles/new'),
                  child: const Text('Write an Article'),
                ),
              ),
            ),

            // Draft Articles Tab
            draftArticles.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, stack) => Center(
                child: Text('Error: ${error.toString()}'),
              ),
              data: (articles) => _ArticlesList(
                articles: articles,
                emptyMessage: 'No draft articles',
                actionButton: ElevatedButton(
                  onPressed: () => context.push('/articles/new'),
                  child: const Text('Create New Draft'),
                ),
              ),
            ),
          ],
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () => context.push('/articles/new'),
          child: const Icon(Icons.add),
        ),
      ),
    );
  }
}

class _ArticlesList extends StatelessWidget {
  final List<Article> articles;
  final String emptyMessage;
  final Widget actionButton;

  const _ArticlesList({
    required this.articles,
    required this.emptyMessage,
    required this.actionButton,
  });

  @override
  Widget build(BuildContext context) {
    if (articles.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.article_outlined,
              size: 64,
              color: Theme.of(context).colorScheme.secondary,
            ),
            const SizedBox(height: 16),
            Text(
              emptyMessage,
              style: Theme.of(context).textTheme.titleLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            actionButton,
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: articles.length,
      itemBuilder: (context, index) {
        final article = articles[index];
        return ArticleCard(
          article: article,
          showActions: true,
        );
      },
    );
  }
}
