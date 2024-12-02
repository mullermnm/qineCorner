import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qine_corner/core/providers/favorite_provider.dart';
import 'package:qine_corner/screens/book/pdf_viewer_screen.dart';
import 'detailed_book_card.dart';

class FavoritesWidget extends ConsumerWidget {
  final bool showTitle;
  final bool showRemoveButton;
  final EdgeInsets? padding;

  const FavoritesWidget({
    super.key,
    this.showTitle = true,
    this.showRemoveButton = false,
    this.padding,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final favoriteBooks = ref.watch(favoriteProvider);

    if (favoriteBooks.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.favorite_border,
              size: 64,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(height: 16),
            Text(
              'No favorite books yet',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(
              'Add some books to your favorites',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).textTheme.bodySmall?.color,
                  ),
            ),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (showTitle) ...[
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              'Your Favorites',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
          ),
          const SizedBox(height: 16),
        ],
        Expanded(
          child: ListView.builder(
            padding: padding ?? const EdgeInsets.all(16),
            itemCount: favoriteBooks.length,
            itemBuilder: (context, index) {
              final book = favoriteBooks[index];
              return Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: Stack(
                  children: [
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => PdfViewerScreen(
                              book: book,
                            ),
                          ),
                        );
                      },
                      child: DetailedBookCard(
                        book: book,
                      ),
                    ),
                    if (showRemoveButton)
                      Positioned(
                        top: 8,
                        right: 8,
                        child: Container(
                          decoration: BoxDecoration(
                            color: Theme.of(context)
                                .colorScheme
                                .surface
                                .withOpacity(0.8),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: IconButton(
                            icon: const Icon(Icons.close),
                            onPressed: () {
                              ref
                                  .read(favoriteProvider.notifier)
                                  .toggleFavorite(book);
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                      '${book.title} removed from favorites'),
                                  duration: const Duration(seconds: 2),
                                ),
                              );
                            },
                            color: Theme.of(context).colorScheme.error,
                            iconSize: 20,
                          ),
                        ),
                      ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
