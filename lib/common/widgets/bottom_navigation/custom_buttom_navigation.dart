import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/providers/books_provider.dart';
import '../../../core/providers/article_provider.dart';
import '../../../core/providers/book_club_provider.dart';

// Create Navigator keys for each tab
final homeNavigatorKey = GlobalKey<NavigatorState>();
final marketNavigatorKey = GlobalKey<NavigatorState>();
final assetsNavigatorKey = GlobalKey<NavigatorState>();
final menuNavigatorKey = GlobalKey<NavigatorState>();

class ScaffoldWithBottomNavBar extends ConsumerStatefulWidget {
  const ScaffoldWithBottomNavBar({
    super.key,
    required this.child,
  });

  final Widget child;

  @override
  ConsumerState<ScaffoldWithBottomNavBar> createState() => _ScaffoldWithBottomNavBarState();
}

class _ScaffoldWithBottomNavBarState extends ConsumerState<ScaffoldWithBottomNavBar> {
  int _currentIndex = 0;
  bool _isRefreshing = false;

  static const List<(String path, String label, IconData icon)> _tabs = [
    ('/', 'Home', Icons.home_rounded),
    ('/articles', 'Articles', Icons.draw),
    ('/book-clubs', 'Book Clubs', Icons.groups_rounded),
    ('/settings', 'Profile', Icons.person_rounded),
  ];

  Future<bool> _systemBackButtonPressed() async {
    final currentNavigatorKey = _getCurrentNavigatorKey();
    if (currentNavigatorKey.currentState?.canPop() == true) {
      currentNavigatorKey.currentState?.pop();
      return false;
    } else {
      return true;
    }
  }

  GlobalKey<NavigatorState> _getCurrentNavigatorKey() {
    switch (_currentIndex) {
      case 0: return homeNavigatorKey;
      case 1: return marketNavigatorKey;
      case 2: return assetsNavigatorKey;
      case 3: return menuNavigatorKey;
      default: return homeNavigatorKey;
    }
  }

  void _onItemTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
    GoRouter.of(context).go(_tabs[index].$1);
  }

  int _calculateSelectedIndex(BuildContext context) {
    final String location = GoRouterState.of(context).uri.toString();
    if (location.startsWith('/articles')) return 1;
    if (location.startsWith('/book-clubs')) return 2;
    if (location.startsWith('/settings')) return 3;
    return 0;
  }

  // Future<void> _handleRefresh() async {
  //   if (_isRefreshing) return;

  //   setState(() => _isRefreshing = true);

  //   try {
  //     // Refresh data based on current route
  //     final location = GoRouterState.of(context).uri.toString();
      
  //     if (location.startsWith('/')) {
  //       // Refresh home data
  //       await ref.refresh(booksProvider);
  //       await ref.refresh(featuredArticlesProvider.future);
  //     } 
  //     else if (location.startsWith('/articles')) {
  //       // Refresh articles
  //       await ref.refresh(articlesProvider.future);
  //     }
  //     else if (location.startsWith('/book-clubs')) {
  //       // Refresh book clubs
  //       await ref.refresh(popularClubsProvider);
  //       await ref.refresh(suggestedClubsProvider);
  //     }
      
  //     if (mounted) {
  //       ScaffoldMessenger.of(context).showSnackBar(
  //         const SnackBar(
  //           content: Text('Refreshed successfully!'),
  //           duration: Duration(seconds: 1),
  //         ),
  //       );
  //     }
  //   } catch (e) {
  //     if (mounted) {
  //       ScaffoldMessenger.of(context).showSnackBar(
  //         SnackBar(
  //           content: Text('Error refreshing: $e'),
  //           backgroundColor: Colors.red,
  //         ),
  //       );
  //     }
  //   } finally {
  //     if (mounted) {
  //       setState(() => _isRefreshing = false);
  //     }
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final selectedIndex = _calculateSelectedIndex(context);
    
    if (_currentIndex != selectedIndex) {
      _currentIndex = selectedIndex;
    }

    return WillPopScope(
      onWillPop: _systemBackButtonPressed,
      child: Scaffold(
      body: widget.child,
        bottomNavigationBar: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Container(
            margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
              color: isDark ? AppColors.darkBackground : Colors.white,
              borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, -5),
            ),
          ],
        ),
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: List.generate(_tabs.length + 1, (index) {
                    if (index == 2) {
                      // Center button placeholder
                      return const SizedBox(width: 60);
                    }
                    
                    final tabIndex = index > 2 ? index - 1 : index;
                    final tab = _tabs[tabIndex];
                    final isSelected = _currentIndex == tabIndex;
                    
                    return Expanded(
                      child: InkWell(
                        onTap: () => _onItemTapped(tabIndex),
                        child: Container(
                          height: 60,
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                    tab.$3,
                                color: isSelected 
                                  ? AppColors.accentMint
                                  : isDark ? AppColors.darkTextSecondary : Colors.grey,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                tab.$2,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: isSelected 
                                    ? AppColors.accentMint
                                    : isDark ? AppColors.darkTextSecondary : Colors.grey,
                                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  }),
                ),
                // Center floating button
                Positioned(
                  top: -25,
                  left: 0,
                  right: 0,
                  child: Center(
                    child: GestureDetector(
                      onTap: () => context.push('/upload-book'),
                      child: Container(
                        width: 65,
                        height: 65,
                        decoration: BoxDecoration(
                    color: AppColors.accentMint,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.accentMint.withOpacity(0.3),
                              blurRadius: 8,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: AnimatedSwitcher(
                          duration: const Duration(milliseconds: 300),
                          child: _isRefreshing
                            ? const CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 3,
                              )
                            : const Icon(
                                Icons.playlist_add_circle,
                                color: Colors.white,
                                size: 32,
                              ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
