import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qine_corner/common/widgets/loading_animation.dart';
import 'package:qine_corner/core/models/book_club.dart';
import 'package:qine_corner/core/models/user_with_role.dart';
import 'package:qine_corner/core/providers/book_club_provider.dart';
import 'package:qine_corner/core/theme/app_colors.dart';

class MembersTab extends ConsumerWidget {
  final BookClub club;

  const MembersTab({
    super.key,
    required this.club,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (club.members.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.group_outlined,
              size: 80,
              color: AppColors.accentMint.withOpacity(0.5),
            ),
            const SizedBox(height: 16),
            Text(
              'No members yet',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: AppColors.accentMint,
                    fontWeight: FontWeight.w500,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              'Invite your friends to join!',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: isDark ? Colors.white70 : Colors.black54,
                  ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: club.members.length,
      itemBuilder: (context, index) {
        final member = club.members[index];
        final isOwner = member.isOwner;

        return Container(
          margin: const EdgeInsets.only(bottom: 16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                if (isOwner) ...[
                  AppColors.accentMint.withOpacity(0.1),
                  AppColors.accentMint.withOpacity(0.05),
                ] else ...[
                  Colors.transparent,
                  Colors.transparent,
                ],
              ],
            ),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isOwner
                  ? AppColors.accentMint.withOpacity(0.2)
                  : Theme.of(context).dividerColor.withOpacity(0.1),
            ),
          ),
          child: ListTile(
            contentPadding: const EdgeInsets.all(16),
            leading: CircleAvatar(
              radius: 28,
              backgroundColor: AppColors.accentMint.withOpacity(0.1),
              backgroundImage: member.profileImage != null
                  ? NetworkImage(member.profileImage!)
                  : null,
              child: member.profileImage == null
                  ? Text(
                      member.name[0].toUpperCase(),
                      style: TextStyle(
                        color: AppColors.accentMint,
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                      ),
                    )
                  : null,
            ),
            title: Row(
              children: [
                Expanded(
                  child: Text(
                    member.name,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ),
                if (isOwner)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          AppColors.accentMint.withOpacity(0.2),
                          AppColors.accentMint.withOpacity(0.4),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.admin_panel_settings,
                          size: 16,
                          color: AppColors.accentMint,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'Admin',
                          style: TextStyle(
                            color: AppColors.accentMint,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 4),
                // Text(
                //   member.email ?? member.phone,
                //   style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                //         color: isDark ? Colors.white70 : Colors.black54,
                //       ),
                // ),
                // const SizedBox(height: 8),
                Text(
                  'Joined ${member.joinedAt}',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: isDark ? Colors.white54 : Colors.black45,
                      ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
