import 'package:flutter/material.dart';
import 'package:qine_corner/core/models/library.dart';
import 'package:qine_corner/core/theme/app_colors.dart';

class LibraryCard extends StatelessWidget {
  final Library library;
  final VoidCallback? onTap;

  const LibraryCard({
    super.key,
    required this.library,
    this.onTap,
  });

  Widget _buildPreviewContent(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return GridView.count(
      crossAxisCount: 2,
      mainAxisSpacing: 8,
      crossAxisSpacing: 8,
      physics: const NeverScrollableScrollPhysics(),
      children: List.generate(4, (index) {
        if (index < library.books.length) {
          // Show actual book cover
          return ClipRRect(
            borderRadius: BorderRadius.circular(0),
            child: Image.asset(
              library.books[index].coverUrl,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  decoration: BoxDecoration(
                    color: isDark
                        ? AppColors.darkSurfaceBackground
                        : AppColors.lightSurfaceBackground,
                    borderRadius: BorderRadius.circular(0),
                  ),
                  child: const Icon(Icons.book, size: 30),
                );
              },
            ),
          );
        } else {
          // Show placeholder book icon for remaining slots
          return Container(
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              Icons.library_books,
              size: 30,
              color: Colors.grey[400],
            ),
          );
        }
      }),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Card(
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      color: isDark
          ? AppColors.darkSurfaceBackground
          : AppColors.lightSurfaceBackground,
      elevation: 2,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Preview Books Grid
            AspectRatio(
              aspectRatio: 1,
              child: Container(
                padding: const EdgeInsets.all(8),
                child: _buildPreviewContent(context),
              ),
            ),
            // Library Info
            Padding(
              padding:
                  const EdgeInsets.only(top: 2, left: 4, right: 4, bottom: 2),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          library.name,
                          style:
                              Theme.of(context).textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: isDark
                                        ? AppColors.darkTextPrimary
                                        : AppColors.lightTextPrimary,
                                  ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${library.bookCount} Books',
                          style:
                              Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: isDark
                                        ? AppColors.darkTextSecondary
                                        : AppColors.lightTextSecondary,
                                  ),
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    Icons.chevron_right,
                    color: isDark
                        ? AppColors.darkTextSecondary
                        : AppColors.lightTextSecondary,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
