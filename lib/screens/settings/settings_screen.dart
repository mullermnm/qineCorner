import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:qine_corner/core/theme/app_colors.dart';
import 'package:qine_corner/core/theme/theme_provider.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentTheme = ref.watch(themeProvider);
    final themeNotifier = ref.read(themeProvider.notifier);
    final isDark = currentTheme == ThemeMode.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: IconButton(
              icon: Icon(
                isDark ? Icons.light_mode : Icons.dark_mode,
                size: 32,
                color: isDark ? Colors.white : AppColors.darkBackground,
              ),
              onPressed: () {
                themeNotifier.setThemeMode(
                  isDark ? ThemeMode.light : ThemeMode.dark,
                );
              },
            ),
          ),
        ],
      ),
      body: ListView(
        children: [
          const SizedBox(height: 16),
          _buildSettingsTile(
            context,
            icon: Icons.favorite,
            title: 'Favorites',
            subtitle: 'View your favorite books',
            onTap: () => context.push('/favorites'),
          ),
          _buildSettingsTile(
            context,
            icon: Icons.download,
            title: 'Downloads',
            subtitle: 'Manage your downloaded books',
            onTap: () => context.push('/downloads'),
          ),
          _buildSettingsTile(
            context,
            icon: Icons.info,
            title: 'About',
            subtitle: 'Learn more about Qine Corner',
            onTap: () {
              showAboutDialog(
                context: context,
                applicationName: 'Qine Corner',
                applicationVersion: '1.0.0',
                applicationIcon: Image.asset(
                  'assets/images/book.png',
                  width: 50,
                  height: 50,
                ),
                children: [
                  const Text(
                    'Qine Corner is a comprehensive mobile application for discovering and managing Ethiopian books with advanced library and reading features.',
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(
        icon,
        size: 28,
        color: Theme.of(context).colorScheme.primary,
      ),
      title: Text(
        title,
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
      ),
      subtitle: Text(
        subtitle,
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).textTheme.bodySmall?.color,
            ),
      ),
      // trailing: Icon(
      //   Icons.chevron_right,
      //   color: Theme.of(context).textTheme.bodySmall?.color,
      // ),
      onTap: onTap,
    );
  }
}
