import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:qine_corner/core/providers/auth_provider.dart';
import 'package:qine_corner/core/theme/theme_provider.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authNotifierProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: authState.when(
        data: (auth) => CustomScrollView(
          slivers: [
            SliverAppBar(
              expandedHeight: 50,
              floating: false,
              pinned: true,
              title: const Text('Settings'),
              flexibleSpace: FlexibleSpaceBar(
                background: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Theme.of(context).colorScheme.primary,
                        Theme.of(context).colorScheme.secondary,
                      ],
                    ),
                  ),
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSectionTitle(context, 'Account'),
                    Card(
                      elevation: 2,
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              isDark
                                  ? Colors.grey[900]!
                                  : Theme.of(context).colorScheme.surface,
                              isDark
                                  ? Colors.grey[850]!
                                  : Theme.of(context).colorScheme.surface,
                            ],
                          ),
                        ),
                        child: Column(
                          children: [
                            if (auth?.user != null)
                              ListTile(
                                leading: Hero(
                                  tag: 'profile-photo',
                                  child: CircleAvatar(
                                    backgroundColor: Theme.of(context)
                                        .colorScheme
                                        .primary
                                        .withOpacity(0.1),
                                    backgroundImage: auth!.user?.profileImage !=
                                            null
                                        ? NetworkImage(auth.user!.profileImage!)
                                        : null,
                                    child: auth.user?.profileImage == null
                                        ? Icon(
                                            Icons.person,
                                            color: Theme.of(context)
                                                .colorScheme
                                                .primary,
                                          )
                                        : null,
                                  ),
                                ),
                                title: Text(auth!.user!.name),
                                subtitle: Text(auth!.user!.phone),
                                trailing: const Icon(Icons.chevron_right),
                                onTap: () => context.push('/profile'),
                              )
                            else
                              ListTile(
                                leading: CircleAvatar(
                                  backgroundColor: Theme.of(context)
                                      .colorScheme
                                      .primary
                                      .withOpacity(0.1),
                                  child: Icon(
                                    Icons.person_outline,
                                    color:
                                        Theme.of(context).colorScheme.primary,
                                  ),
                                ),
                                title: const Text('Sign in'),
                                subtitle: const Text(
                                    'Tap to sign in or create an account'),
                                trailing: const Icon(Icons.chevron_right),
                                onTap: () => context.push('/login'),
                              ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    _buildSectionTitle(context, 'Reading'),
                    Card(
                      elevation: 2,
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              isDark
                                  ? Colors.grey[900]!
                                  : Theme.of(context).colorScheme.surface,
                              isDark
                                  ? Colors.grey[850]!
                                  : Theme.of(context).colorScheme.surface,
                            ],
                          ),
                        ),
                        child: Column(
                          children: [
                            _buildSettingsTile(
                              context,
                              icon: Icons.book,
                              title: 'Reading Preferences',
                              subtitle: 'Goals, notifications, and more',
                              onTap: () {
                                if (auth?.user == null) {
                                  context.push('/login');
                                  return;
                                }
                                context.push('/reading-preferences');
                              },
                            ),
                            const Divider(height: 1),
                            _buildSettingsTile(
                              context,
                              icon: Icons.download,
                              title: 'Downloads',
                              subtitle: 'Manage your downloaded content',
                              onTap: () {
                                if (auth?.user == null) {
                                  context.push('/login');
                                  return;
                                }
                                context.push('/downloads');
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    _buildSectionTitle(context, 'Appearance'),
                    Card(
                      elevation: 2,
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              isDark
                                  ? Colors.grey[900]!
                                  : Theme.of(context).colorScheme.surface,
                              isDark
                                  ? Colors.grey[850]!
                                  : Theme.of(context).colorScheme.surface,
                            ],
                          ),
                        ),
                        child: SwitchListTile(
                          secondary: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Theme.of(context)
                                  .colorScheme
                                  .primary
                                  .withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Icon(
                              isDark ? Icons.dark_mode : Icons.light_mode,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                          ),
                          title: const Text('Dark Mode'),
                          subtitle: Text(
                            isDark
                                ? 'Dark theme enabled'
                                : 'Light theme enabled',
                          ),
                          value: isDark,
                          onChanged: (value) {
                            ref.read(themeProvider.notifier).toggleTheme();
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    _buildSectionTitle(context, 'Support'),
                    Card(
                      elevation: 2,
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              isDark
                                  ? Colors.grey[900]!
                                  : Theme.of(context).colorScheme.surface,
                              isDark
                                  ? Colors.grey[850]!
                                  : Theme.of(context).colorScheme.surface,
                            ],
                          ),
                        ),
                        child: Column(
                          children: [
                            _buildSettingsTile(
                              context,
                              icon: Icons.help_outline,
                              title: 'Help & Support',
                              onTap: () {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content:
                                        Text('Help & Support coming soon!'),
                                    behavior: SnackBarBehavior.floating,
                                  ),
                                );
                              },
                            ),
                            const Divider(height: 1),
                            _buildSettingsTile(
                              context,
                              icon: Icons.info_outline,
                              title: 'About',
                              onTap: () {
                                showAboutDialog(
                                  context: context,
                                  applicationName: 'Qine Corner',
                                  applicationVersion: '1.0.0',
                                  applicationLegalese: ' 2025 Qine Corner',
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Text('Error: $error'),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: Theme.of(context).colorScheme.primary,
              fontWeight: FontWeight.bold,
            ),
      ),
    );
  }

  Widget _buildSettingsTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    String? subtitle,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(
          icon,
          color: Theme.of(context).colorScheme.primary,
        ),
      ),
      title: Text(title),
      subtitle: subtitle != null ? Text(subtitle) : null,
      trailing: const Icon(Icons.chevron_right),
      onTap: onTap,
    );
  }
}
