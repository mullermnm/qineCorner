import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qine_corner/core/providers/favorite_provider.dart';
import 'package:qine_corner/core/providers/library_provider.dart';
import 'package:qine_corner/core/models/book.dart';
import 'package:qine_corner/core/theme/app_colors.dart';
import 'package:qine_corner/core/theme/theme_helper.dart';
import 'package:qine_corner/core/config/app_config.dart';
import 'package:qine_corner/screens/library/widgets/add_to_libraries_dialog.dart';
import '../book_detail_screen.dart';

class BookCard extends ConsumerWidget {
  final Book book;
  final VoidCallback? onTap;

  const BookCard({
    super.key,
    required this.book,
    this.onTap,
  });

  void _showAddToLibrariesDialog(BuildContext context, WidgetRef ref) {
    final libraries = ref.read(libraryProvider);

    showDialog(
      context: context,
      builder: (context) => AddToLibrariesDialog(
        libraries: libraries,
        book: book,
        onAddToLibrary: (library) {
          ref.read(libraryProvider.notifier).addBookToLibrary(library.id, book);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Added "${book.title}" to "${library.name}"'),
              backgroundColor: Colors.green,
            ),
          );
        },
        onCreateLibrary: (name) {
          ref
              .read(libraryProvider.notifier)
              .addLibrary(name, initialBook: book);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Created library "$name" with "${book.title}"'),
              backgroundColor: Colors.green,
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final favorites = ref.watch(favoriteProvider);
    final isFavorite = favorites.any((b) => b.id == book.id);

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => BookDetailScreen(book: book),
          ),
        );
        onTap?.call();
      },
      child: Card(
        elevation: 2,
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(
            color:
                isDark ? AppColors.darkBackground : AppColors.lightBackground,
            width: 1,
          ),
        ),
        child: SizedBox(
          height: 280,
          child: Column(
            children: [
              Expanded(
                flex: 8,
                child: Stack(
                  children: [
                    SizedBox.expand(
                      child: book.coverUrl != null && book.coverUrl!.isNotEmpty
                          ? Image.network(
                              AppConfig.getAssetUrl(book.coverUrl),
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                print('Error loading image: $error');
                                return _buildPlaceholder();
                              },
                              loadingBuilder:
                                  (context, child, loadingProgress) {
                                if (loadingProgress == null) return child;
                                return Center(
                                  child: CircularProgressIndicator(
                                    value: loadingProgress.expectedTotalBytes !=
                                            null
                                        ? loadingProgress
                                                .cumulativeBytesLoaded /
                                            loadingProgress.expectedTotalBytes!
                                        : null,
                                  ),
                                );
                              },
                            )
                          : _buildPlaceholder(),
                    ),
                    Positioned(
                      top: 8,
                      right: 8,
                      child: Row(
                        children: [
                          IconButton(
                            icon: Icon(
                              isFavorite
                                  ? Icons.favorite
                                  : Icons.favorite_border,
                              color: isFavorite ? Colors.red : Colors.white,
                            ),
                            onPressed: () {
                              ref
                                  .read(favoriteProvider.notifier)
                                  .toggleFavorite(book);
                            },
                            iconSize: 20,
                            constraints: const BoxConstraints(
                              minWidth: 32,
                              minHeight: 32,
                            ),
                            padding: EdgeInsets.zero,
                          ),
                          const SizedBox(width: 3),
                          IconButton(
                            icon: const Icon(
                              Icons.bookmark_border,
                              color: Colors.white,
                              size: 24,
                            ),
                            onPressed: () =>
                                _showAddToLibrariesDialog(context, ref),
                            constraints: const BoxConstraints(),
                            padding: EdgeInsets.zero,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                flex: 3,
                child: Padding(
                  padding: const EdgeInsets.only(
                      top: 1, left: 1, right: 4, bottom: 1),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        book.title,
                        style:
                            Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        book.author.name,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Theme.of(context)
                                  .textTheme
                                  .bodyMedium
                                  ?.color
                                  ?.withOpacity(0.7),
                            ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPlaceholder() {
    return Container(
      color: Colors.grey.shade300,
      child: const Center(
        child: Icon(
          Icons.book,
          size: 40,
          color: Colors.grey,
        ),
      ),
    );
  }
}
