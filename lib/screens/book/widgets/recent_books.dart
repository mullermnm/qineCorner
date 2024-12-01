import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/models/book.dart';
import '../../../core/providers/books_provider.dart';
import '../../../common/widgets/app_text.dart';
import '../../../common/widgets/loading_animation.dart';
import '../../../screens/error/widgets/animated_error_widget.dart';
import 'book_card.dart';

class RecentBooks extends ConsumerWidget {
  const RecentBooks({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final booksAsync = ref.watch(booksProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: AppText.h2('Recent Books'),
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 280, // Adjust this height based on your BookCard height
          child: booksAsync.when(
            loading: () => const LoadingAnimation(),
            error: (error, stack) => AnimatedErrorWidget(
              message: 'Failed to load recent books. Please try again.',
              onRetry: () => ref.invalidate(booksProvider),
            ),
            data: (books) {
              if (books.isEmpty) {
                return const Center(
                  child: Text('No recent books found'),
                );
              }

              // Take only the first 10 books for recent
              final recentBooks = books.take(10).toList();

              return ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: recentBooks.length,
                itemBuilder: (context, index) {
                  final book = recentBooks[index];
                  return Padding(
                    padding: const EdgeInsets.only(right: 16),
                    child: SizedBox(
                      width: 160, // Fixed width for each card
                      child: BookCard(
                        book: book,
                        onTap: () {
                          // Handle book tap
                          debugPrint('Tapped on recent book: ${book.title}');
                        },
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }
}
