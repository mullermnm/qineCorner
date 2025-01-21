import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:qine_corner/core/models/library.dart';
import 'package:qine_corner/core/providers/library_provider.dart';
import 'package:qine_corner/screens/book/pdf_viewer_screen.dart';
import 'package:qine_corner/screens/book/widgets/detailed_book_card.dart';
import 'package:qine_corner/common/widgets/loading_animation.dart';
import 'package:qine_corner/screens/error/widgets/animated_error_widget.dart';

class LibraryDetailScreen extends ConsumerWidget {
  final Library library;

  const LibraryDetailScreen({
    super.key,
    required this.library,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch the library provider to get updates
    final libraries = ref.watch(libraryProvider);
    final currentLibrary = libraries.firstWhere(
      (lib) => lib.id == library.id,
      orElse: () => library,
    );

    Future<bool> _showDeleteConfirmation() async {
      return await showDialog<bool>(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('Delete Library'),
              content: Text(
                  'Are you sure you want to delete "${currentLibrary.name}"? This action cannot be undone.'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context, false),
                  child: const Text('Cancel'),
                ),
                TextButton(
                  onPressed: () => Navigator.pop(context, true),
                  style: TextButton.styleFrom(
                    foregroundColor: Theme.of(context).colorScheme.error,
                  ),
                  child: const Text('Delete'),
                ),
              ],
            ),
          ) ??
          false;
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(currentLibrary.name),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/libraries'),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {
              // TODO: Implement library edit functionality
            },
          ),
          IconButton(
            icon: const Icon(Icons.delete),
            color: Theme.of(context).colorScheme.error,
            onPressed: () async {
              final shouldDelete = await _showDeleteConfirmation();
              if (shouldDelete && context.mounted) {
                await ref
                    .read(libraryProvider.notifier)
                    .deleteLibrary(currentLibrary.id);
                if (context.mounted) {
                  context.go('/libraries');
                }
              }
            },
          ),
        ],
      ),
      body: currentLibrary.books.isEmpty
          ? AnimatedErrorWidget(
              message: 'No books found in this library',
              onRetry: () => ref.invalidate(libraryProvider),
            )
          : ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: currentLibrary.books.length,
              separatorBuilder: (context, index) => const SizedBox(height: 16),
              itemBuilder: (context, index) {
                final book = currentLibrary.books[index];
                return Stack(
                  children: [
                    DetailedBookCard(
                      book: book,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ProviderScope(
                              child: PdfViewerScreen(
                                book: book,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                    Positioned(
                      top: 8,
                      right: 8,
                      child: Container(
                        child: IconButton(
                          icon: const Icon(Icons.close),
                          color: Theme.of(context).colorScheme.error,
                          iconSize: 22,
                          constraints: const BoxConstraints(
                            minWidth: 32,
                            minHeight: 32,
                          ),
                          padding: EdgeInsets.zero,
                          onPressed: () async {
                            final shouldRemove = await showDialog<bool>(
                                  context: context,
                                  builder: (context) => AlertDialog(
                                    title: const Text('Remove Book'),
                                    content: Text(
                                        'Remove "${book.title}" from this library?'),
                                    actions: [
                                      TextButton(
                                        onPressed: () =>
                                            Navigator.pop(context, false),
                                        child: const Text('Cancel'),
                                      ),
                                      TextButton(
                                        onPressed: () =>
                                            Navigator.pop(context, true),
                                        style: TextButton.styleFrom(
                                          foregroundColor: Theme.of(context)
                                              .colorScheme
                                              .error,
                                        ),
                                        child: const Text('Remove'),
                                      ),
                                    ],
                                  ),
                                ) ??
                                false;

                            if (shouldRemove && context.mounted) {
                              await ref
                                  .read(libraryProvider.notifier)
                                  .removeBookFromLibrary(
                                    currentLibrary.id,
                                    book,
                                  );
                            }
                          },
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
      // floatingActionButton: FloatingActionButton(
      //   onPressed: () {
      //     // TODO: Implement add book functionality
      //   },
      //   child: const Icon(Icons.add),
      // ),
    );
  }
}
