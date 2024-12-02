import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qine_corner/common/widgets/app_text.dart';
import '../../../core/models/book.dart';
import '../../../core/providers/books_provider.dart';
import '../../../screens/error/widgets/animated_error_widget.dart';
import '../../../common/widgets/loading_animation.dart';
import 'book_card.dart';

class BooksGrid extends ConsumerWidget {
  const BooksGrid({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Load all books when mounted
    Future.microtask(() {
      ref.read(booksProvider.notifier).filterByCategory(null);
    });

    final booksAsync = ref.watch(booksProvider);

    return booksAsync.when(
      loading: () => const LoadingAnimation(),
      error: (error, stack) => AnimatedErrorWidget(
        message: 'Failed to load books. Please try again.',
        onRetry: () => ref.invalidate(booksProvider),
      ),
      data: (books) {
        if (books.isEmpty) {
          return AnimatedErrorWidget(
            message: 'Failed to load books. Please try again.',
            onRetry: () => ref.invalidate(booksProvider),
          );
        }

        return BooksGridWidget(
          books: books,
          onLoadMore: () {
            ref.read(booksProvider.notifier).loadMoreBooks();
          },
        );
      },
    );
  }
}

class BooksGridWidget extends StatefulWidget {
  final List<Book> books;
  final VoidCallback? onLoadMore;

  const BooksGridWidget({
    super.key,
    required this.books,
    this.onLoadMore,
  });

  @override
  State<BooksGridWidget> createState() => _BooksGridWidgetState();
}

class _BooksGridWidgetState extends State<BooksGridWidget> {
  static const int _itemsPerPage = 8;
  bool _isLoadingMore = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: AppText.h2('Popular Books'),
        ),
        const SizedBox(height: 6),
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
