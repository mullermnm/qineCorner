import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:qine_corner/core/models/category.dart';
import 'package:qine_corner/screens/home/widgets/home_content.dart';
import '../../../core/models/book.dart';
import '../../../core/providers/books_provider.dart';
import '../../../screens/error/widgets/animated_error_widget.dart';
import '../../../common/widgets/loading_animation.dart';
import 'book_card.dart';

class CategoryBooksList extends ConsumerStatefulWidget {
  final String categoryId;

  const CategoryBooksList({
    super.key,
    required this.categoryId,
  });

  @override
  ConsumerState<CategoryBooksList> createState() => _CategoryBooksListState();
}

class _CategoryBooksListState extends ConsumerState<CategoryBooksList> {
  String? _lastFilteredCategory;
  
  @override
  void initState() {
    super.initState();
    // Delay provider update until after the build cycle
    Future.microtask(() => _filterBooks(widget.categoryId));
  }
  
  @override
  void didUpdateWidget(CategoryBooksList oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.categoryId != oldWidget.categoryId) {
      // Delay provider update until after the build cycle
      Future.microtask(() => _filterBooks(widget.categoryId));
    }
  }
  
  void _filterBooks(String categoryId) {
    if (_lastFilteredCategory != categoryId) {
      _lastFilteredCategory = categoryId;
      // Only filter if we haven't already filtered for this category
      ref.read(booksProvider.notifier).filterByCategory(categoryId);
    }
  }

  @override
  Widget build(BuildContext context) {
    // Watch for changes in the book state
    final booksAsync = ref.watch(booksProvider);
    
    return booksAsync.books.when(
      loading: () => const LoadingAnimation(),
      error: (error, stack) => AnimatedErrorWidget(
        message: 'Failed to load books for this category. Please try again.',
        onRetry: () {
          ref.invalidate(booksProvider);
          _filterBooks(widget.categoryId);
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
                debugPrint('Tapped on book: ${book.title}');
                // Navigate to book details
                context.push('/book/${book.id}', extra: book);
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
