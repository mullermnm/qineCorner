import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qine_corner/common/widgets/primary_button.dart';
import 'package:qine_corner/common/widgets/secondary_button.dart';
import 'package:qine_corner/core/services/download_service.dart';
import '../../core/models/book.dart';
import '../../core/models/category.dart';
import '../../core/theme/app_colors.dart';
import '../../common/widgets/app_text.dart';
import '../../common/widgets/cached_image.dart';
import '../../common/widgets/loading_animation.dart';
import '../../core/providers/categories_provider.dart';
import '../../core/providers/favorite_provider.dart';
import '../../screens/error/widgets/animated_error_widget.dart';
import 'pdf_viewer_screen.dart';
import 'package:go_router/go_router.dart';
import 'widgets/more_from_author.dart';

class BookDetailScreen extends ConsumerWidget {
  final Book book;

  const BookDetailScreen({super.key, required this.book});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final size = MediaQuery.of(context).size;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final categoriesAsync = ref.watch(categoriesProvider);
    final favorites = ref.watch(favoriteProvider);
    final isFavorite = favorites.any((b) => b.id == book.id);

    Future<void> _downloadBook(BuildContext context, WidgetRef ref) async {
      final fileName = book.filePath.split('/').last;
      await DownloadService.downloadPDF(
        book.filePath,
        fileName,
        context,
        ref,
      );
    }

    void _toggleFavorite() {
      ref.read(favoriteProvider.notifier).toggleFavorite(book);
    }

    return Scaffold(
      body: categoriesAsync.when(
        loading: () => const Center(child: LoadingAnimation()),
        error: (error, stack) => AnimatedErrorWidget(
          message: 'Failed to load book details',
          onRetry: () => ref.refresh(categoriesProvider),
        ),
        data: (categories) => SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Book Cover Image with curved bottom corners
              Stack(
                children: [
                  CachedImage(
                    imagePath: book.coverUrl,
                    height: size.height * 0.5,
                    width: double.infinity,
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(30),
                      bottomRight: Radius.circular(30),
                    ),
                  ),
                  // Back Button
                  Positioned(
                    top: MediaQuery.of(context).padding.top + 10,
                    left: 16,
                    child: Container(
                      decoration: BoxDecoration(
                        color: isDark ? Colors.black54 : Colors.white54,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: IconButton(
                        icon: const Icon(Icons.arrow_back),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ),
                  ),
                  Positioned(
                    top: MediaQuery.of(context).padding.top + 10,
                    right: 16,
                    child: Container(
                      decoration: BoxDecoration(
                        color: isDark ? Colors.black54 : Colors.white54,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: IconButton(
                        icon: Icon(
                          isFavorite ? Icons.favorite : Icons.favorite_border,
                          color: isFavorite ? Colors.red : null,
                        ),
                        onPressed: _toggleFavorite,
                      ),
                    ),
                  ),
                ],
              ),

              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Book Title and Year
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: AppText.h1(book.title),
                        ),
                        if (book.publishYear != null)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: isDark
                                  ? AppColors.darkSurfaceBackground
                                  : AppColors.lightSurfaceBackground,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: AppText.body(
                              book.publishYear.toString(),
                              color: isDark
                                  ? AppColors.darkTextSecondary
                                  : AppColors.lightTextSecondary,
                              bold: false,
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 8),

                    // Author and Rating Row
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        AppText.body(
                          'By ${book.author.name}',
                          color: isDark
                              ? AppColors.darkTextSecondary
                              : AppColors.lightTextSecondary,
                          bold: false,
                        ),
                        Row(
                          children: [
                            const Icon(
                              Icons.star,
                              color: Colors.amber,
                              size: 24,
                            ),
                            const SizedBox(width: 4),
                            AppText.body(
                              '${book.rating}/5',
                              color: isDark
                                  ? AppColors.darkTextSecondary
                                  : AppColors.lightTextSecondary,
                              bold: true,
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),

                    // Categories with box shadow
                    SizedBox(
                      height: 40,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: book.categories.length,
                        itemBuilder: (context, index) {
                          final categoryId = book.categories[index];
                          final category = categories.firstWhere(
                            (c) => c.id == categoryId,
                            orElse: () => Category(
                              icon: "question_mark",
                              id: categoryId,
                              name: 'Unknown Category',
                              bookCount: 0,
                            ),
                          );

                          return Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 8,
                              ),
                              decoration: BoxDecoration(
                                color: isDark
                                    ? AppColors.darkSurfaceBackground
                                    : AppColors.lightSurfaceBackground,
                                borderRadius: BorderRadius.circular(20),
                                boxShadow: [
                                  BoxShadow(
                                    color: isDark
                                        ? Colors.black.withOpacity(0.2)
                                        : Colors.grey.withOpacity(0.2),
                                    spreadRadius: 1,
                                    blurRadius: 4,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    category.icon,
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: isDark
                                          ? AppColors.darkTextSecondary
                                          : AppColors.lightTextSecondary,
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  AppText.body(
                                    category.name,
                                    color: isDark
                                        ? AppColors.darkTextSecondary
                                        : AppColors.lightTextSecondary,
                                    bold: false,
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 10),

                    // Description
                    AppText.h2('Description'),
                    const SizedBox(height: 8),
                    AppText.body(
                      book.description,
                      color: isDark
                          ? AppColors.darkTextSecondary
                          : AppColors.lightTextSecondary,
                      bold: false,
                    ),

                    const SizedBox(height: 10),

                    // Action Buttons
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 5,
                        vertical: 16,
                      ),
                      child: LayoutBuilder(
                        builder: (context, constraints) {
                          final showLabels = constraints.maxWidth > 300;
                          return Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              Expanded(
                                child: PrimaryButton(
                                  onPressed: () => _downloadBook(context, ref),
                                  text: showLabels ? 'Download' : '',
                                  icon: Icons.download_rounded,
                                  padding:
                                      const EdgeInsets.symmetric(horizontal: 8),
                                ),
                              ),
                              const SizedBox(width: 5),
                              Expanded(
                                child: SecondaryButton(
                                  onPressed: _toggleFavorite,
                                  text: showLabels ? 'Favorite' : '',
                                  icon: isFavorite
                                      ? Icons.favorite_rounded
                                      : Icons.favorite_border_rounded,
                                  outlined: false,
                                  padding:
                                      const EdgeInsets.symmetric(horizontal: 8),
                                ),
                              ),
                              const SizedBox(width: 5),
                              Expanded(
                                child: SecondaryButton(
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => PdfViewerScreen(
                                          book: book,
                                        ),
                                      ),
                                    );
                                  },
                                  text: showLabels ? 'Read' : '',
                                  icon: Icons.menu_book_rounded,
                                  outlined: true,
                                  padding:
                                      const EdgeInsets.symmetric(horizontal: 8),
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 10),

                    // More from author section
                    MoreFromAuthor(currentBook: book),
                    const SizedBox(height: 10),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
