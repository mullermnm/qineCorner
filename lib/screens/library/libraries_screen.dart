import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qine_corner/common/widgets/loading_animation.dart';
import 'package:qine_corner/core/providers/library_provider.dart';
import 'package:qine_corner/screens/library/widgets/library_card.dart';
import 'package:qine_corner/core/theme/app_colors.dart';
import 'package:go_router/go_router.dart';

class LibrariesScreen extends ConsumerStatefulWidget {
  const LibrariesScreen({super.key});

  @override
  ConsumerState<LibrariesScreen> createState() => _LibrariesScreenState();
}

class _LibrariesScreenState extends ConsumerState<LibrariesScreen> {
  int displayCount = 4;
  bool isLoading = false;

  Future<void> _loadMore() async {
    setState(() {
      isLoading = true;
    });

    // Simulate loading delay
    await Future.delayed(const Duration(milliseconds: 800));

    setState(() {
      displayCount += 4;
      isLoading = false;
    });
  }

  Future<String?> _showCreateLibraryDialog(BuildContext context) {
    final controller = TextEditingController();
    return showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Create Library'),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(
            hintText: 'Library name',
            border: OutlineInputBorder(),
          ),
          onSubmitted: (value) => Navigator.pop(context, value),
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

  @override
  Widget build(BuildContext context) {
    final libraries = ref.watch(libraryProvider);
    final displayedLibraries = libraries.take(displayCount).toList();
    final hasMoreLibraries = libraries.length > displayCount;

    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.lightBackground,
      appBar: AppBar(
        title: const Text('My Libraries'),
        backgroundColor: isDark ? AppColors.darkSurfaceBackground : AppColors.lightSurfaceBackground,
      ),
      body: libraries.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.library_books,
                    size: 64,
                    color: isDark
                        ? AppColors.darkTextSecondary
                        : AppColors.lightTextSecondary,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No libraries yet',
                    style: TextStyle(
                      color: isDark
                          ? AppColors.darkTextSecondary
                          : AppColors.lightTextSecondary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Create a library to start organizing your books',
                    style: TextStyle(
                      color: isDark
                          ? AppColors.darkTextSecondary
                          : AppColors.lightTextSecondary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            )
          : Column(
              children: [
                Expanded(
                  child: GridView.builder(
                    padding: const EdgeInsets.all(16),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio: 0.75,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                    ),
                    itemCount: displayedLibraries.length,
                    itemBuilder: (context, index) {
                      final library = displayedLibraries[index];
                      return LibraryCard(
                        library: library,
                        onTap: () => context.go('/library/${library.id}'),
                      );
                    },
                  ),
                ),
                if (hasMoreLibraries)
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: isLoading
                        ? const LoadingAnimation()
                        : TextButton.icon(
                            onPressed: _loadMore,
                            icon: const Icon(Icons.expand_more),
                            label: const Text('Show More Libraries'),
                          ),
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
    );
  }
}
