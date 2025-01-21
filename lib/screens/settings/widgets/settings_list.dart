import 'package:flutter/material.dart';
import 'package:qine_corner/core/theme/app_colors.dart';

class SettingsList extends StatelessWidget {
  final bool isLoggedIn;
  final VoidCallback? onLogout;

  const SettingsList({
    super.key,
    required this.isLoggedIn,
    this.onLogout,
  });

  Widget _buildSettingsTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback? onTap,
    bool requiresAuth = false,
  }) {
    final bool isEnabled = !requiresAuth || isLoggedIn;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurfaceBackground : AppColors.lightSurfaceBackground,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ListTile(
        onTap: isEnabled ? onTap : null,
        contentPadding: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        leading: Icon(
          icon,
          color: isEnabled
              ? (isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary)
              : Colors.grey,
        ),
        title: Text(
          title,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: isEnabled
                    ? (isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary)
                    : Colors.grey,
              ),
        ),
        subtitle: Text(
          subtitle,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: isEnabled
                    ? (isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary)
                    : Colors.grey,
              ),
        ),
        trailing: isEnabled
            ? Icon(
                Icons.chevron_right,
                color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
              )
            : const Icon(Icons.lock_outline, color: Colors.grey),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
        _buildSettingsTile(
          context,
          icon: Icons.notifications_outlined,
          title: 'Notifications',
          subtitle: 'Manage your notification preferences',
          onTap: () {},
          requiresAuth: true,
        ),
        _buildSettingsTile(
          context,
          icon: Icons.book_outlined,
          title: 'Reading Preferences',
          subtitle: 'Customize your reading experience',
          onTap: () {},
          requiresAuth: true,
        ),
        _buildSettingsTile(
          context,
          icon: Icons.privacy_tip_outlined,
          title: 'Privacy',
          subtitle: 'Control your privacy settings',
          onTap: () {},
        ),
        _buildSettingsTile(
          context,
          icon: Icons.help_outline,
          title: 'Help & Support',
          subtitle: 'Get help or contact support',
          onTap: () {},
        ),
        _buildSettingsTile(
          context,
          icon: Icons.info_outline,
          title: 'About',
          subtitle: 'Learn more about Qine Corner',
          onTap: () {},
        ),
        if (isLoggedIn && onLogout != null) ...[
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: ElevatedButton(
              onPressed: onLogout,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red.shade100,
                foregroundColor: Colors.red,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'Logout',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
        const SizedBox(height: 24),
      ],
    );
  }
}
