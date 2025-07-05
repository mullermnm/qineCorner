import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qine_corner/common/widgets/primary_button.dart';
import 'package:qine_corner/common/widgets/secondary_button.dart';
import 'package:qine_corner/core/services/download_service.dart';
import 'package:qine_corner/features/book_rating/presentation/widgets/book_ratings_section.dart';
import 'package:qine_corner/features/book_rating/presentation/widgets/star_rating_widget.dart';
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
                            StarRatingWidget(
                              rating: book.rating ?? 0.0,
                              size: 18,
                              activeColor: Colors.amber,
                            ),
                            const SizedBox(width: 4),
                            AppText.body(
                              '${book.rating ?? 0.0}/5',
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
                          // Extract category information directly from the map
                          Category categoryData;
                          
                          // Handle different formats
                          if (book.categories[index] is Map) {
                            // If it's already a Map, create a Category from it
                            final catMap = book.categories[index] as Map<dynamic, dynamic>;
                            categoryData = Category(
                              id: catMap['id']?.toString() ?? '',
                              name: catMap['name']?.toString() ?? 'Unknown',
                              icon: catMap['icon']?.toString() ?? 'category',
                              booksCount: 0,
                            );
                          } else {
                            // If it's just an ID, try to find it in the categories list
                            final categoryId = book.categories[index].id;
                            categoryData = categories.firstWhere(
                              (c) => c.id == categoryId,
                              orElse: () => Category(
                                icon: "category",
                                id: categoryId,
                                name: 'Category $categoryId',
                                booksCount: 0,
                              ),
                            );
                          }
                          
                          // Get name and icon
                          final name = categoryData.name;
                          final iconName = categoryData.icon;
                          
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
                                    color: Colors.black.withOpacity(0.1),
                                    blurRadius: 4,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    _getCategoryIcon(iconName!),
                                    size: 16,
                                    color: _getCategoryColor(name),
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    name,
                                    style: TextStyle(
                                      color: _getCategoryColor(name),
                                      fontWeight: FontWeight.bold,
                                    ),
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
                                  iconColor: AppColors.darkBackground,
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
                                        builder: (context) => ProviderScope(
                                          child: PdfViewerScreen(
                                            book: book,
                                          ),
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
                    const SizedBox(height: 30),

                    // More from author section
                    MoreFromAuthor(currentBook: book),
                    const SizedBox(height: 30),
                    
                    // Book ratings section
                    BookRatingsSection(bookId: book.id),
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

  IconData _getCategoryIcon(String iconName) {
    switch (iconName.toLowerCase()) {
      case 'auto_stories': return Icons.auto_stories;
      case 'castle': return Icons.castle;
      case 'casino': return Icons.casino;
      case 'rocket': return Icons.rocket;
      case 'search': return Icons.search;
      case 'favorite': return Icons.favorite;
      case 'psychology': return Icons.psychology;
      case 'dangerous': return Icons.dangerous;
      case 'history_edu': return Icons.history_edu;
      case 'person': return Icons.person;
      default: return Icons.category;
    }
  }

  Color _getCategoryColor(String categoryName) {
    switch (categoryName.toLowerCase()) {
      case 'fiction': return Colors.blue;
      case 'fantasy': return Colors.purple;
      case 'mystery': return Colors.amber;
      case 'romance': return Colors.pink;
      case 'thriller': return Colors.red;
      case 'horror': return Colors.deepOrange;
      case 'sci-fi': return Colors.indigo;
      case 'science fiction': return Colors.indigo;
      case 'biography': return Colors.teal;
      case 'history': return Colors.brown;
      default: return Colors.grey;
    }
  }
}
