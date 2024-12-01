import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';

class ScaffoldWithBottomNavBar extends StatefulWidget {
  const ScaffoldWithBottomNavBar({
    super.key,
    required this.child,
  });

  final Widget child;

  @override
  State<ScaffoldWithBottomNavBar> createState() =>
      _ScaffoldWithBottomNavBarState();
}

class _ScaffoldWithBottomNavBarState extends State<ScaffoldWithBottomNavBar> {
  int _currentIndex = 0;

  static const List<(String path, String label, IconData icon)> _tabs = [
    ('/home', 'Home', Icons.home_outlined),
    ('/downloads', 'Downloads', Icons.download_outlined),
    ('/settings', 'Settings', Icons.settings_outlined),
  ];

  void _onTap(BuildContext context, int index) {
    if (index == _currentIndex) return;
    
    setState(() => _currentIndex = index);
    context.go(_tabs[index].$1);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: widget.child,
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkBackground : AppColors.lightBackground,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: NavigationBar(
          height: 65,
          elevation: 0,
          selectedIndex: _currentIndex,
          onDestinationSelected: (index) => _onTap(context, index),
          backgroundColor: Colors.transparent,
          indicatorColor: isDark 
              ? AppColors.accentMint.withOpacity(0.2)
              : AppColors.accentMint.withOpacity(0.4),
          destinations: _tabs
              .map(
                (tab) => NavigationDestination(
                  icon: Icon(
                    tab.$3,
                    color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                  ),
                  selectedIcon: Icon(
                    tab.$3,
                    color: AppColors.accentMint,
                  ),
                  label: tab.$2,
                ),
              )
              .toList(),
        ),
      ),
    );
  }
}
