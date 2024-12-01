import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import 'background_wave.dart';
import 'search_bar_widget.dart';

class SliverSearchAppBar extends SliverPersistentHeaderDelegate {
  final Function(String) onSearch;

  const SliverSearchAppBar({
    required this.onSearch,
  });

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    var adjustedShrinkOffset =
        shrinkOffset > minExtent ? minExtent : shrinkOffset;
    double offset = (minExtent - adjustedShrinkOffset) * 0.5;
    double topPadding = MediaQuery.of(context).padding.top + 16;

    // Calculate title animation
    final scrollProgress = shrinkOffset / (maxExtent - minExtent);
    final titleOffset =
        80 * scrollProgress; // Move up by 80 pixels when scrolled

    return Stack(
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
            child: Image.asset(
              'assets/images/book.png',
              height: 120,
              fit: BoxFit.contain,
            ),
          ),
        ),
        Positioned(
          top: topPadding + 15 - titleOffset, // Start lower and move up
          left: 24,
          child: Text(
            'Qine Corner',
            textAlign: TextAlign.right,
            style: TextStyle(
              fontSize: 28 - (scrollProgress * 8), // Shrink text as it scrolls
              fontWeight: FontWeight.bold,
              color: Theme.of(context).scaffoldBackgroundColor,
            ),
          ),
        ),
        Positioned(
          top: topPadding + offset,
          left: 16,
          right: 16,
          child: SearchBarWidget(onSearch: onSearch),
        ),
      ],
    );
  }

  @override
  double get maxExtent => 280;

  @override
  double get minExtent => 140;

  @override
  bool shouldRebuild(covariant SliverPersistentHeaderDelegate oldDelegate) =>
      oldDelegate.maxExtent != maxExtent || oldDelegate.minExtent != minExtent;
}
