import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qine_corner/screens/error/widgets/animated_error_widget.dart';
import '../../../core/providers/books_provider.dart';
import '../../../common/widgets/loading_animation.dart';
import 'book_card.dart';

class RecentBooks extends ConsumerWidget {
  const RecentBooks({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final booksAsync = ref.watch(recentBooksProvider);
    print(
        'RecentBooks widget build - state: ${booksAsync.value != null ? 'has data' : 'no data'}');
    if (booksAsync.value != null) {
      print('Books count in widget: ${booksAsync.value!.length}');
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Padding(
        //   padding: const EdgeInsets.symmetric(horizontal: 16),
        //   child: Text(
        //     'Recent Books',
        //     style: Theme.of(context).textTheme.titleLarge,
        //   ),
        // ),
        const SizedBox(height: 16),
        SizedBox(
          height: 280,
          child: booksAsync.when(
            loading: () {
              print('RecentBooks: Loading state');
              return const Center(child: LoadingAnimation());
            },
            error: (error, stackTrace) {
              print('RecentBooks: Error state - $error');
              return Center(
                child: AnimatedErrorWidget(
                  message: 'Error loading recent books',
                  onRetry: () => ref.invalidate(recentBooksProvider),
                ),
              );
            },
            data: (books) {
              print('RecentBooks: Data state - ${books.length} books');
              if (books.isEmpty) {
                return const Center(
                  child: Text('No recent books found'),
                );
              }

              return GridView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.all(16),
                physics: const BouncingScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 1,
                  childAspectRatio: 1.4,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                ),
                itemCount: books.length,
                itemBuilder: (context, index) {
                  final book = books[index];
                  return Padding(
                    padding: const EdgeInsets.only(right: 16),
                    child: SizedBox(
                      width: 160,
                      child: BookCard(
                        book: book,
                        onTap: () {
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
