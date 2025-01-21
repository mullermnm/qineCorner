import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:qine_corner/core/models/book_club.dart';
import 'package:qine_corner/core/providers/auth_provider.dart';
import 'package:qine_corner/core/providers/book_club_provider.dart';
import 'package:qine_corner/core/services/book_club_service.dart';
import 'package:qine_corner/core/theme/app_colors.dart';

class PopularClubsSection extends ConsumerStatefulWidget {
  final List<BookClub> clubs;

  const PopularClubsSection({
    super.key,
    required this.clubs,
  });

  @override
  ConsumerState<PopularClubsSection> createState() =>
      _PopularClubsSectionState();
}

class _PopularClubsSectionState extends ConsumerState<PopularClubsSection> {
  Future<void> _joinClub(BookClub club) async {
    try {
      final service = ref.read(bookClubServiceProvider);
      final updatedClub = await service.joinBookClub(club.id.toString());

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.check_circle, color: Colors.white),
                const SizedBox(width: 8),
                Text('Successfully joined ${club.name}!'),
              ],
            ),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );

        context.push('/book-clubs/${updatedClub.id}');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.error_outline, color: Colors.white),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Failed to join club: ${e.toString()}',
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Popular Now',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppColors.accentMint,
                    ),
              ),
              TextButton.icon(
                onPressed: () => context.push('/book-clubs/popular'),
                icon: const Icon(Icons.arrow_forward),
                label: const Text('See All'),
                style: TextButton.styleFrom(
                  foregroundColor: AppColors.accentMint,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 220,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: widget.clubs.length + 1,
            itemBuilder: (context, index) {
              if (index == widget.clubs.length) {
                return Container(
                  width: 160,
                  margin: const EdgeInsets.only(right: 16),
                  child: Card(
                    elevation: 2,
                    clipBehavior: Clip.antiAlias,
                    child: InkWell(
                      onTap: () => context.push('/book-clubs/popular'),
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              AppColors.accentMint.withOpacity(0.1),
                              AppColors.accentMint.withOpacity(0.2),
                            ],
                          ),
                        ),
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.explore,
                                size: 32,
                                color: AppColors.accentMint,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'See All\nPopular Clubs',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: AppColors.accentMint,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              }

              final club = widget.clubs[index];
              final authState = ref.watch(authNotifierProvider);
              final currentUser = authState.value?.user;
              final isOwner = currentUser?.id == club.owner.id;
              final isMember = club.members.any((member) => member.id == currentUser?.id);

              return Container(
                width: 280,
                margin: const EdgeInsets.only(right: 16),
                child: Card(
                  elevation: 2,
                  clipBehavior: Clip.antiAlias,
                  child: InkWell(
                    onTap: () => context.push('/book-clubs/${club.id}'),
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        if (club.imageUrl != null)
                          Image.network(
                            club.imageUrl!,
                            fit: BoxFit.cover,
                          )
                        else
                          Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  AppColors.accentMint.withOpacity(0.1),
                                  AppColors.accentMint.withOpacity(0.05),
                                ],
                              ),
                            ),
                            child: Icon(
                              Icons.menu_book_rounded,
                              size: 64,
                              color: AppColors.accentMint,
                            ),
                          ),
                        Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Colors.transparent,
                                Colors.black.withOpacity(0.8),
                              ],
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      club.name,
                                      style: Theme.of(context)
                                          .textTheme
                                          .titleLarge
                                          ?.copyWith(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                          ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.black26,
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(
                                          Icons.people,
                                          size: 14,
                                          color: AppColors.accentMint,
                                        ),
                                        const SizedBox(width: 4),
                                        Text(
                                          '${club.memberCount}',
                                          style: TextStyle(
                                            color: AppColors.accentMint,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Text(
                                club.description,
                                style: const TextStyle(
                                  color: Colors.white70,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 12),
                              Wrap(
                                spacing: 8,
                                runSpacing: 8,
                                children: [
                                  ...club.genres.take(2).map((genre) {
                                    return Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 4,
                                      ),
                                      decoration: BoxDecoration(
                                        color: AppColors.accentMint.withOpacity(0.2),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Text(
                                        genre,
                                        style: TextStyle(
                                          color: AppColors.accentMint,
                                          fontSize: 12,
                                        ),
                                      ),
                                    );
                                  }),
                                ],
                              ),
                              const SizedBox(height: 12),
                              if (!club.isPrivate && !isOwner && !isMember)
                                FilledButton(
                                  onPressed: () => _joinClub(club),
                                  style: FilledButton.styleFrom(
                                    backgroundColor: AppColors.accentMint,
                                    foregroundColor: Colors.white,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: const [
                                      Icon(Icons.add, size: 16),
                                      SizedBox(width: 4),
                                      Text('Join Club'),
                                    ],
                                  ),
                                )
                              else if (isOwner)
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 6,
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
                                        size: 14,
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
                                )
                              else if (isMember)
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 6,
                                  ),
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [
                                        AppColors.accentMint.withOpacity(0.1),
                                        AppColors.accentMint.withOpacity(0.2),
                                      ],
                                    ),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        Icons.people,
                                        size: 14,
                                        color: AppColors.accentMint,
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        'Member',
                                        style: TextStyle(
                                          color: AppColors.accentMint,
                                          fontWeight: FontWeight.w500,
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
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
