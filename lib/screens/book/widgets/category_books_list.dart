import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:qine_corner/screens/home/widgets/home_content.dart';
import '../../../core/models/book.dart';
import '../../../core/providers/books_provider.dart';
import '../../../screens/error/widgets/animated_error_widget.dart';
import '../../../common/widgets/loading_animation.dart';
import 'book_card.dart';

class CategoryBooksList extends ConsumerWidget {
  final String categoryId;
  final String title;

  const CategoryBooksList({
    super.key,
    required this.categoryId,
    required this.title,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ref.watch(booksProvider).books.when(
          data: (books) {
            if (books.isEmpty) {
              return const SizedBox.shrink();
            }

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        title,
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      TextButton(
                        onPressed: () {
                          // Navigate to category view
                        },
                        child: const Text('See All'),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                SizedBox(
                  height: 280,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: books.length,
                    itemBuilder: (context, index) {
                      final book = books[index];
                      return Padding(
                        padding: const EdgeInsets.only(right: 16),
                        child: SizedBox(
                          width: 160,
                          child: BookCard(
                            book: book,
                            onTap: () =>
                                context.push('/book/${book.id}', extra: book),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, stack) => Center(
            child: Text('Error: $error'),
          ),
        );
  }
}

class CategoryBooksListView extends StatefulWidget {
  final List<Book> books;
  final VoidCallback? onLoadMore;

  const CategoryBooksListView({
    super.key,
    required this.books,
    this.onLoadMore,
  });

  @override
  State<CategoryBooksListView> createState() => _CategoryBooksListViewState();
}

class _CategoryBooksListViewState extends State<CategoryBooksListView> {
  static const int _itemsPerPage = 8;
  bool _isLoadingMore = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 0.82,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
          ),
          itemCount: widget.books.length,
          itemBuilder: (context, index) {
            final book = widget.books[index];
            return BookCard(
              book: book,
              onTap: () {
                // Handle book tap
                debugPrint('Tapped on book: ${book.title}');
              },
            );
          },
        ),
        if (widget.books.length >= _itemsPerPage && widget.onLoadMore != null)
          Padding(
            padding: const EdgeInsets.only(top: 16.0),
            child: _isLoadingMore
                ? const LoadingAnimation()
                : TextButton(
                    onPressed: () async {
                      setState(() => _isLoadingMore = true);
                      await Future.delayed(
                        const Duration(milliseconds: 300),
                        widget.onLoadMore,
                      );
                      setState(() => _isLoadingMore = false);
                    },
                    child: const Text('Show More'),
                  ),
          ),
      ],
    );
  }
}
