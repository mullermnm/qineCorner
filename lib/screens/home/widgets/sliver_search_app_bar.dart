import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:qine_corner/core/providers/books_provider.dart';
import '../../../core/theme/app_colors.dart';
import 'background_wave.dart';
import 'search_bar_widget.dart';

class SliverSearchAppBar extends SliverPersistentHeaderDelegate {
  final double expandedHeight = 280;
  final double collapsedHeight = 140;
  final BuildContext context;
  final void Function(String) onSearchChanged;

  SliverSearchAppBar({
    required this.context,
    required this.onSearchChanged,
  });

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    final progress = shrinkOffset / expandedHeight;
    final showTitle = progress > 0.5;

    var adjustedShrinkOffset =
        shrinkOffset > minExtent ? minExtent : shrinkOffset;
    double offset = (minExtent - adjustedShrinkOffset) * 0.5;
    double topPadding = MediaQuery.of(context).padding.top + 16;

    // Calculate title animation
    final scrollProgress = shrinkOffset / (maxExtent - minExtent);
    final titleOffset =
        80 * scrollProgress; // Move up by 80 pixels when scrolled

    return Stack(
      fit: StackFit.expand,
      children: [
        BackgroundWave(
          height: 280,
          scrollProgress: scrollProgress,
        ),
        Positioned(
          right: 0,
          top: topPadding + titleOffset,
          child: Opacity(
              opacity:
                  1 - (scrollProgress * 2).clamp(0.0, 1.0), // Fade out faster
              child: Row(children: [
                IconButton(
                    onPressed: () {
                      context.go('/upload-book');
                    },
                    icon: Icon(Icons.local_library)),
                IconButton(
                    onPressed: () {
                      context.go('/articles');
                    },
                    icon: Icon(Icons.auto_stories)),
              ])),
        ),
        Positioned(
          left: 16,
          right: 16,
          top: 16 + topPadding + titleOffset + 5,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (!showTitle) ...[
                Text(
                  'Qine Corner',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 8),
              ],
              Consumer(
                builder: (context, ref, child) {
                  return Container(
                    height: 44,
                    decoration: BoxDecoration(
                      color: Theme.of(context).cardColor,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: TextField(
                      onChanged: (query) {
                        onSearchChanged(query);
                        ref.read(booksProvider.notifier).searchBooks(query);
                      },
                      decoration: InputDecoration(
                        hintText: 'Search books...',
                        prefixIcon: const Icon(Icons.search),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
        if (showTitle)
          Positioned(
            left: 16,
            top: MediaQuery.of(context).padding.top + 16,
            child: Text(
              '',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
          ),
      ],
    );
  }

  @override
  double get maxExtent => expandedHeight;

  @override
  double get minExtent => collapsedHeight;

  @override
  bool shouldRebuild(covariant SliverPersistentHeaderDelegate oldDelegate) {
    return true;
  }
}
