import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qine_corner/screens/home/widgets/home_content.dart';
import '../../../core/models/book.dart';
import '../../../core/providers/books_provider.dart';
import '../../../screens/error/widgets/animated_error_widget.dart';
import '../../../common/widgets/loading_animation.dart';
import 'book_card.dart';

class CategoryBooksList extends ConsumerWidget {
  final String categoryId;

  const CategoryBooksList({
    super.key,
    required this.categoryId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Initial filter on mount
    Future.microtask(() {
      ref.read(booksProvider.notifier).filterByCategory(categoryId);
    });

    // Watch for selected category changes
    final selectedCategory = ref.watch(selectedCategoryProvider);

    // Only update if the selected category is different from current
    if (selectedCategory != categoryId) {
      Future.microtask(() {
        ref.read(booksProvider.notifier).filterByCategory(selectedCategory);
      });
    }

    final booksAsync = ref.watch(booksProvider);

    return booksAsync.when(
      loading: () => const LoadingAnimation(),
      error: (error, stack) => AnimatedErrorWidget(
        message: 'Failed to load books for this category. Please try again.',
        onRetry: () {
          ref.invalidate(booksProvider);
          ref.read(booksProvider.notifier).filterByCategory(categoryId);
        },
      ),
      data: (books) {
        if (books.isEmpty) {
          return const Center(
            child: Text('No books found in this category'),
          );
        }

        return CategoryBooksListView(
          books: books,
          onLoadMore: () {
            ref.read(booksProvider.notifier).loadMoreBooks();
          },
        );
      },
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
  static const int _itemsPerPage = 9;
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
