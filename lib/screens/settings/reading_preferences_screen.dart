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
    final AuthState = ref.watch(authNotifierProvider);
    final user = AuthState.when(
      data: (state) => state?.user,
      loading: () => null,
      error: (_, __) => null,
    );
    return Scaffold(
      appBar: AppBar(
        title: const Text('Reading Preferences'),
      ),
      body: ListView(
        children: [
          if (user != null) ...[
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Theme.of(context).colorScheme.secondary,
                    Theme.of(context).colorScheme.tertiary,
                  ],
                ),
                boxShadow: [
                  BoxShadow(
                    color: Theme.of(context).shadowColor.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Hero(
                    tag: 'profile-avatar',
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Theme.of(context).colorScheme.onSecondary.withOpacity(0.5),
                          width: 2,
                        ),
                      ),
                      child: CircleAvatar(
                        radius: 45,
                        backgroundColor: Theme.of(context).colorScheme.surface,
                        child: Text(
                          user.name[0].toUpperCase(),
                          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                                color: Theme.of(context).colorScheme.secondary,
                              ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    user.name,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: Theme.of(context).colorScheme.onSecondary,
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  Text(
                    user.phone,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context).colorScheme.onSecondary.withOpacity(0.8),
                        ),
                  ),
                ],
              ),
            ),
          ],
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSectionTitle(context, 'Reading Goals'),
                Card(
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  elevation: 2,
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Theme.of(context).colorScheme.primaryContainer.withOpacity(0.5),
                          Theme.of(context).colorScheme.primaryContainer.withOpacity(0.2),
                        ],
                      ),
                    ),
                    child: ListTile(
                      contentPadding: const EdgeInsets.all(16),
                      leading: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          Icons.track_changes,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                      title: const Text('Set Reading Goals'),
                      subtitle: const Text('Track your reading progress'),
                      trailing: Icon(
                        Icons.chevron_right,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      onTap: () => context.push('/goal-setup'),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                _buildSectionTitle(context, 'Notifications'),
                Card(
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  elevation: 2,
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Theme.of(context).colorScheme.secondaryContainer.withOpacity(0.5),
                          Theme.of(context).colorScheme.secondaryContainer.withOpacity(0.2),
                        ],
                      ),
                    ),
                    child: Column(
                      children: [
                        SwitchListTile(
                          contentPadding: const EdgeInsets.all(16),
                          title: const Text('Reading Reminders'),
                          subtitle: const Text('Daily reminders to read'),
                          value: true, // TODO: Connect to actual preference
                          onChanged: (value) {
                            // TODO: Implement notification toggle
                          },
                          secondary: Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Theme.of(context).colorScheme.secondary.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(
                              Icons.notifications_active,
                              color: Theme.of(context).colorScheme.secondary,
                            ),
                          ),
                        ),
                        const Divider(height: 1),
                        SwitchListTile(
                          contentPadding: const EdgeInsets.all(16),
                          title: const Text('Book Club Updates'),
                          subtitle: const Text('Updates from your book clubs'),
                          value: true, // TODO: Connect to actual preference
                          onChanged: (value) {
                            // TODO: Implement notification toggle
                          },
                          secondary: Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Theme.of(context).colorScheme.secondary.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(
                              Icons.group,
                              color: Theme.of(context).colorScheme.secondary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                _buildSectionTitle(context, 'Appearance'),
                Card(
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  elevation: 2,
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Theme.of(context).colorScheme.tertiaryContainer.withOpacity(0.5),
                          Theme.of(context).colorScheme.tertiaryContainer.withOpacity(0.2),
                        ],
                      ),
                    ),
                    child: SwitchListTile(
                      contentPadding: const EdgeInsets.all(16),
                      title: const Text('Dark Mode'),
                      subtitle: Text(
                        isDark ? 'Dark theme enabled' : 'Light theme enabled',
                      ),
                      value: isDark,
                      onChanged: (value) {
                        ref.read(themeProvider.notifier).toggleTheme();
                      },
                      secondary: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.tertiary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          isDark ? Icons.dark_mode : Icons.light_mode,
                          color: Theme.of(context).colorScheme.tertiary,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
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
}
