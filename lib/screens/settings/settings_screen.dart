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
        title: Text(
          'Solo Reader',
          style: TextStyle(
            color: Theme.of(context).primaryColor,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: authState.when(
        data: (auth) => SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Premium Card
              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(15),
                    gradient: LinearGradient(
                      colors: [
                        Theme.of(context).primaryColor.withOpacity(0.8),
                        Theme.of(context).primaryColor,
                      ],
                    ),
                  ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                      Row(
                        children: [
                          const Text(
                            'Upgrade to Premium',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Icon(
                            Icons.star_rounded,
                            color: Colors.amber[300],
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Enjoy an Ad-Free Experience – Upgrade to Premium for Seamless Browsing',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.9),
                          fontSize: 13,
                        ),
                              ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

              // Remove Ads Section
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                    color: Colors.red.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.block, color: Colors.red),
                ),
                title: const Text('Remove Ads Only'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {
                  // Handle remove ads
                },
              ),
              const Divider(),

              // Account & Content Section
              _buildSectionTitle(context, 'Account & Content'),
              if (auth?.user != null)
                _buildSettingsTile(
                  context,
                  icon: Icons.person,
                  title: auth!.user!.name,
                  subtitle: auth.user!.phone,
                  onTap: () => context.push('/profile'),
                ),
              _buildSettingsTile(
                context,
                icon: Icons.book_outlined,
                title: 'My Book Requests',
                onTap: () => context.push('/my-requests'),
              ),
              _buildSettingsTile(
                context,
                icon: Icons.language,
                title: 'Language',
                onTap: () {
                  // Handle language selection
                },
              ),

              // Preferences Section
              _buildSectionTitle(context, 'Preferences'),
                            _buildSettingsTile(
                              context,
                icon: Icons.book_outlined,
                              title: 'Reading Preferences',
                              onTap: () {
                                context.push('/reading-preferences');
                              },
                            ),
                            _buildSettingsTile(
                              context,
                icon: Icons.privacy_tip_outlined,
                title: 'Terms & Privacy',
                              onTap: () {
                  // Handle terms of services
                },
              ),
              _buildSettingsTile(
                context,
                icon: Icons.info_outline,
                title: 'About App',
                onTap: () {
                  showAboutDialog(
                    context: context,
                    applicationName: 'Qine Corner',
                    applicationVersion: '1.0.0',
                    applicationLegalese: '© 2025 Qine Corner',
                  );
                },
              ),

              // Social Section
              _buildSectionTitle(context, 'Social'),
              _buildSettingsTile(
                context,
                icon: Icons.star_outline,
                title: 'Rate Us',
                onTap: () {
                  // Handle rate us
                },
              ),
              _buildSettingsTile(
                context,
                icon: Icons.share_outlined,
                title: 'Share with Friends',
                onTap: () {
                  // Handle share
                },
              ),
              _buildSettingsTile(
                context,
                icon: Icons.apps_outlined,
                title: 'More Apps',
                onTap: () {
                  // Handle more apps
                },
              ),

              // Theme Toggle
              SwitchListTile(
                          secondary: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                    color: Theme.of(context).primaryColor.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Icon(
                              isDark ? Icons.dark_mode : Icons.light_mode,
                    color: Theme.of(context).primaryColor,
                            ),
                          ),
                          title: const Text('Dark Mode'),
                          value: isDark,
                          onChanged: (value) {
                            ref.read(themeProvider.notifier).toggleTheme();
                          },
                        ),

              // Restore Purchase Button
              const SizedBox(height: 24),
              Center(
                child: TextButton(
                  onPressed: () {
                    // Handle restore purchase
                  },
                  child: Text(
                    'Restore Purchase',
                    style: TextStyle(
                      color: Theme.of(context).primaryColor.withOpacity(0.7),
                    ),
                        ),
                      ),
                    ),
                  ],
                ),
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(child: Text('Error: $error')),
      ),
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 4),
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
          color: Theme.of(context).primaryColor.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(
          icon,
          color: Theme.of(context).primaryColor,
        ),
      ),
      title: Text(title),
      subtitle: subtitle != null ? Text(subtitle) : null,
      trailing: const Icon(Icons.chevron_right, size: 20),
      onTap: onTap,
    );
  }
}
