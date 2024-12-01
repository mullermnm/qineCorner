import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../common/widgets/app_text.dart';
import 'wave_clipper.dart';
import 'search_bar_widget.dart';

class WaveAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final Function(String) onSearch;
  final double scrollProgress;
  final bool showSearchBar;

  const WaveAppBar({
    super.key,
    required this.title,
    required this.onSearch,
    this.scrollProgress = 0.0,
    this.showSearchBar = true,
  });

  @override
  Size get preferredSize => const Size.fromHeight(270);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return SizedBox(
      width: double.infinity,
      height: 270,
      child: Stack(
        children: [
          ClipPath(
            clipper: WaveClipper(progress: scrollProgress),
            child: Container(
              width: double.infinity,
              height: 270,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    AppColors.accentMint,
                    AppColors.accentMint.withOpacity(0.8),
                  ],
                ),
              ),
              child: SafeArea(
                bottom: false,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Opacity(
                    opacity: scrollProgress,
                    child: AppText.h1(
                      title,
                      color: isDark ? AppColors.darkTextPrimary : Colors.white,
                    ),
                  ),
                ),
              ),
            ),
          ),
          if (showSearchBar)
            Positioned(
              bottom: 30 + (70 * scrollProgress),
              left: 16 + (40 * scrollProgress),
              right: 16 + (40 * scrollProgress),
              child: SearchBarWidget(onSearch: onSearch),
            ),
        ],
      ),
    );
  }
}
