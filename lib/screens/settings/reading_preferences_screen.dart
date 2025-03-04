import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:qine_corner/core/providers/auth_provider.dart';
import 'package:qine_corner/core/theme/theme_provider.dart';

class ReadingPreferencesScreen extends ConsumerWidget {
  const ReadingPreferencesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final authState = ref.watch(authNotifierProvider);
    final user = authState.whenOrNull(data: (state) => state?.user);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Reading Preferences'),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Column(
        children: [
            if (user != null)
            Container(
                width: double.infinity,
                margin: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                      Theme.of(context).primaryColor,
                      Theme.of(context).primaryColor.withOpacity(0.8),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Stack(
                  children: [
                    Positioned(
                      right: -20,
                      top: -20,
                      child: Icon(
                        Icons.book_rounded,
                        size: 150,
                        color: Colors.white.withOpacity(0.1),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(20),
                      child: Row(
                children: [
                  Hero(
                    tag: 'profile-avatar',
                      child: CircleAvatar(
                              radius: 30,
                              backgroundColor: Colors.white,
                        child: Text(
                          user.name[0].toUpperCase(),
                                style: TextStyle(
                                  color: Theme.of(context).primaryColor,
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                        ),
                      ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                  Text(
                    user.name,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  Text(
                    user.phone,
                                  style: TextStyle(
                                    color: Colors.white.withOpacity(0.9),
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                        ),
                  ),
                ],
              ),
            ),
          ],
                ),
              ),

            // Reading Goals Section
          Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSectionTitle(context, 'Reading Goals'),
                Card(
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: BorderSide(
                        color: Theme.of(context).primaryColor.withOpacity(0.1),
                      ),
                    ),
                    child: ListTile(
                      contentPadding: const EdgeInsets.all(16),
                      leading: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Theme.of(context).primaryColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          Icons.track_changes,
                          color: Theme.of(context).primaryColor,
                        ),
                      ),
                      title: const Text('Set Reading Goals'),
                      subtitle: const Text('Track your reading progress'),
                      trailing: Icon(
                        Icons.chevron_right,
                        color: Theme.of(context).primaryColor,
                      ),
                      onTap: () => context.push('/goal-setup'),
                    ),
                  ),

                const SizedBox(height: 24),
                _buildSectionTitle(context, 'Notifications'),
                Card(
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: BorderSide(
                        color: Theme.of(context).primaryColor.withOpacity(0.1),
                      ),
                    ),
                    child: Column(
                      children: [
                        _buildSwitchTile(
                          context,
                          title: 'Reading Reminders',
                          subtitle: 'Daily reminders to read',
                          icon: Icons.notifications_active,
                          value: true,
                          onChanged: (value) {
                            // TODO: Implement notification toggle
                          },
                        ),
                        Divider(
                          height: 1,
                          color: Theme.of(context).primaryColor.withOpacity(0.1),
                        ),
                        _buildSwitchTile(
                          context,
                          title: 'Book Club Updates',
                          subtitle: 'Updates from your book clubs',
                          icon: Icons.group,
                          value: true,
                          onChanged: (value) {
                            // TODO: Implement notification toggle
                          },
                        ),
                      ],
                    ),
                  ),

                const SizedBox(height: 24),
                _buildSectionTitle(context, 'Appearance'),
                Card(
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: BorderSide(
                        color: Theme.of(context).primaryColor.withOpacity(0.1),
                      ),
                    ),
                    child: _buildSwitchTile(
                      context,
                      title: 'Dark Mode',
                      subtitle: isDark ? 'Dark theme enabled' : 'Light theme enabled',
                      icon: isDark ? Icons.dark_mode : Icons.light_mode,
                      value: isDark,
                      onChanged: (value) {
                        ref.read(themeProvider.notifier).toggleTheme();
                      },
                    ),
                  ),
                  const SizedBox(height: 24),
              ],
            ),
          ),
        ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
      child: Text(
        title,
        style: TextStyle(
          color: Theme.of(context).primaryColor,
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildSwitchTile(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return SwitchListTile(
      contentPadding: const EdgeInsets.all(16),
      title: Text(title),
      subtitle: Text(subtitle),
      value: value,
      onChanged: onChanged,
      secondary: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Theme.of(context).primaryColor.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(
          icon,
          color: Theme.of(context).primaryColor,
            ),
      ),
    );
  }
}
