import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lottie/lottie.dart';
import 'package:qine_corner/common/widgets/loading_animation.dart';
import 'package:qine_corner/core/models/book.dart';
import 'package:qine_corner/core/providers/library_provider.dart';
import 'package:qine_corner/core/providers/book_shelf_provider.dart';
import 'package:qine_corner/screens/book/pdf_viewer_screen.dart';
import 'package:qine_corner/screens/library/widgets/library_card.dart';
import 'package:qine_corner/screens/library/widgets/recently_opened_books.dart';
import 'package:qine_corner/core/theme/app_colors.dart';
import 'package:qine_corner/screens/notes/notes_screen.dart';
import 'package:go_router/go_router.dart';

class LibrariesScreen extends ConsumerStatefulWidget {
  const LibrariesScreen({super.key});

  @override
  ConsumerState<LibrariesScreen> createState() => _LibrariesScreenState();
}

class _LibrariesScreenState extends ConsumerState<LibrariesScreen> {
  int displayCount = 4;

  Future<void> _loadMore() async {
    setState(() {
      displayCount += 10;
    });
  }

  void _surpriseMe() {
    final librariesAsync = ref.watch(libraryProvider.notifier).state;
    if (librariesAsync == null || librariesAsync.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No books available to surprise you!'),
        ),
      );
      return;
    }

    final random = Random();
    final randomLibrary = librariesAsync[random.nextInt(librariesAsync.length)];
    if (randomLibrary.books.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Selected library has no books!'),
        ),
      );
      return;
    }

    final randomBook =
        randomLibrary.books[random.nextInt(randomLibrary.books.length)];
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ProviderScope(
          child: PdfViewerScreen(
            book: randomBook,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final libraries = ref.watch(libraryProvider.notifier).state;

    if (libraries == null) {
      return const Scaffold(
        body: Center(
          child: LoadingAnimation(),
        ),
      );
    }

    final displayedLibraries = libraries.take(displayCount).toList();
    final hasMore = libraries.length > displayCount;

    return DefaultTabController(
      length: 4,
      child: Scaffold(
        appBar: AppBar(
          toolbarHeight: 80,
          title: const Text('Library'),
          actions: [
            GestureDetector(
              onTap: _surpriseMe,
              child: Lottie.asset(
                'assets/animations/surpriseButton.json',
                fit: BoxFit.cover,
                repeat: true,
                onLoaded: (composition) {
                  // You can configure the Lottie animation controller here if needed
                },
              ),
            ),
          ],
          bottom: const TabBar(
            isScrollable: true,
            tabs: [
              Tab(text: 'All Books'),
              Tab(text: 'Currently Reading'),
              Tab(text: 'To Read'),
              Tab(text: 'Finished'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            // All Books Tab
            Column(
              children: [
                const RecentlyOpenedBooks(),
                Expanded(
                  child: libraries.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.library_books,
                                size: 64,
                                color: Theme.of(context).disabledColor,
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'No libraries yet',
                                style: TextStyle(
                                  color: Theme.of(context).disabledColor,
                                ),
                              ),
                            ],
                          ),
                        )
                      : GridView.builder(
                          padding: const EdgeInsets.all(16),
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            childAspectRatio: 0.75,
                            crossAxisSpacing: 16,
                            mainAxisSpacing: 16,
                          ),
                          itemCount:
                              displayedLibraries.length + (hasMore ? 1 : 0),
                          itemBuilder: (context, index) {
                            if (index == displayedLibraries.length) {
                              return TextButton(
                                onPressed: () {
                                  setState(() {
                                    displayCount += 10;
                                  });
                                },
                                child: const Text('Show More'),
                              );
                            }
                            final library = displayedLibraries[index];
                            return LibraryCard(
                              library: library,
                              onTap: () {
                                context.push('/library/${library.id}',
                                    extra: library);
                              },
                            );
                          },
                        ),
                ),
              ],
            ),
            // Currently Reading Tab
            ref.watch(bookShelfProvider).when(
                  data: (shelves) {
                    return _buildShelfGrid(
                      shelves[BookShelf.currentlyReading] ?? [],
                    );
                  },
                  loading: () => const Center(child: LoadingAnimation()),
                  error: (error, _) => Center(child: Text('Error: $error')),
                ),
            // To Read Tab
            ref.watch(bookShelfProvider).when(
                  data: (shelves) {
                    return _buildShelfGrid(
                      shelves[BookShelf.toRead] ?? [],
                    );
                  },
                  loading: () => const Center(child: LoadingAnimation()),
                  error: (error, _) => Center(child: Text('Error: $error')),
                ),
            // Finished Tab
            ref.watch(bookShelfProvider).when(
                  data: (shelves) {
                    return _buildShelfGrid(
                      shelves[BookShelf.finished] ?? [],
                    );
                  },
                  loading: () => const Center(child: LoadingAnimation()),
                  error: (error, _) => Center(child: Text('Error: $error')),
                ),
          ],
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () async {
            final name = await _showCreateLibraryDialog(context);
            if (name != null && name.isNotEmpty && context.mounted) {
              await ref.read(libraryProvider.notifier).addLibrary(name);
            }
          },
          child: const Icon(Icons.add),
        ),
      ),
    );
  }

  Widget _buildShelfGrid(List<Book> books) {
    if (books.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.book,
              size: 64,
              color: Theme.of(context).disabledColor,
            ),
            const SizedBox(height: 16),
            Text(
              'No books in this shelf',
              style: TextStyle(
                color: Theme.of(context).disabledColor,
              ),
            ),
          ],
        ),
      );
    }

    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.75,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemCount: books.length,
      itemBuilder: (context, index) {
        final book = books[index];
        return GestureDetector(
          onTap: () {
            context.push('/book/${book.id}', extra: book);
          },
          onLongPress: () {
            _showMoveToShelfDialog(book);
          },
          child: Card(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  child: Image.asset(
                    book.coverUrl,
                    fit: BoxFit.cover,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    book.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _showMoveToShelfDialog(Book book) async {
    final shelf = await showDialog<BookShelf>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Move to Shelf'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: const Text('Currently Reading'),
              onTap: () => Navigator.pop(context, BookShelf.currentlyReading),
            ),
            ListTile(
              title: const Text('To Read'),
              onTap: () => Navigator.pop(context, BookShelf.toRead),
            ),
            ListTile(
              title: const Text('Finished'),
              onTap: () => Navigator.pop(context, BookShelf.finished),
            ),
          ],
        ),
      ),
    );

    if (shelf != null && mounted) {
      await ref.read(bookShelfProvider.notifier).addBookToShelf(book, shelf);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                'Moved "${book.title}" to ${shelf.toString().split('.').last}'),
          ),
        );
      }
    }
  }

  Future<String?> _showCreateLibraryDialog(BuildContext context) {
    final controller = TextEditingController();
    return showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Create Library'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            labelText: 'Library Name',
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, controller.text),
            child: const Text('Create'),
          ),
        ],
      ),
    );
  }
}
