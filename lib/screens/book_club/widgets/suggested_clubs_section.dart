import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:qine_corner/core/models/book_club.dart';
import 'package:qine_corner/core/providers/auth_provider.dart';
import 'package:qine_corner/core/providers/book_club_provider.dart';
import 'package:qine_corner/core/services/book_club_service.dart';
import 'package:qine_corner/core/theme/app_colors.dart';

class SuggestedClubsSection extends ConsumerStatefulWidget {
  final List<BookClub> clubs;

  const SuggestedClubsSection({
    super.key,
    required this.clubs,
  });

  @override
  ConsumerState<SuggestedClubsSection> createState() =>
      _SuggestedClubsSectionState();
}

class _SuggestedClubsSectionState extends ConsumerState<SuggestedClubsSection> {
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

  Widget _buildJoinButton(BookClub club) {
    final authState = ref.watch(authNotifierProvider);
    final currentUser = authState.value?.user;
    final isMember = club.members.any((member) => member.id == currentUser?.id);
    final isOwner = club.owner.id == currentUser?.id;

    if (isOwner) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
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
      );
    }

    if (isMember) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
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
              size: 16,
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
      );
    }

    return FilledButton(
      onPressed: () {
        if (currentUser == null) {
          context.push('/login');
          return;
        }
        _joinClub(club);
      },
      style: FilledButton.styleFrom(
        backgroundColor: AppColors.accentMint,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        padding: const EdgeInsets.symmetric(
          horizontal: 24,
          vertical: 12,
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
    );
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
                'Suggested for You',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppColors.accentMint,
                    ),
              ),
              TextButton.icon(
                onPressed: () => context.push('/book-clubs/suggested'),
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
            scrollDirection: Axis.vertical,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: widget.clubs.length,
            itemBuilder: (context, index) {
              final club = widget.clubs[index];
              final authState = ref.watch(authNotifierProvider);
              final currentUser = authState.value?.user;
              final isOwner = currentUser?.id == club.owner!.id ?? false;
              final isMember =
                  club.members.any((member) => member.id == currentUser?.id) ??
                      false;
              return Container(
                width: double.infinity,
                margin: const EdgeInsets.only(bottom: 16),
                child: Card(
                  elevation: 2,
                  clipBehavior: Clip.antiAlias,
                  child: InkWell(
                    onTap: () => context.push('/book-clubs/${club.id}'),
                    child: Container(
                      height: 200,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            AppColors.accentMint.withOpacity(0.05),
                            Colors.transparent,
                          ],
                        ),
                        border: Border.all(
                          color: AppColors.accentMint.withOpacity(0.1),
                        ),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ClipRRect(
                            borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(12),
                              bottomLeft: Radius.circular(12),
                            ),
                            child: SizedBox(
                              width: 80,
                              height: double.infinity,
                              child: Stack(
                                fit: StackFit.expand,
                                children: [
                                  Container(
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        colors: [
                                          AppColors.accentMint.withOpacity(0.1),
                                          AppColors.accentMint
                                              .withOpacity(0.05),
                                        ],
                                      ),
                                    ),
                                  ),
                                  if (club.imageUrl != null)
                                    Image.network(
                                      club.imageUrl!,
                                      fit: BoxFit.cover,
                                    )
                                  else
                                    Center(
                                      child: Icon(
                                        Icons.menu_book_rounded,
                                        size: 48,
                                        color: AppColors.accentMint,
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          ),
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
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
                                                fontWeight: FontWeight.bold,
                                              ),
                                        ),
                                      ),
                                      Column(
                                        children: [
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 8,
                                              vertical: 4,
                                            ),
                                            decoration: BoxDecoration(
                                              color: isDark
                                                  ? Colors.black12
                                                  : Colors.white60,
                                              borderRadius:
                                                  BorderRadius.circular(8),
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
                                          SizedBox(
                                            height: 40,
                                          ),
                                          if (!club.isPrivate &&
                                              !isOwner &&
                                              !isMember)
                                            FilledButton(
                                              onPressed: () async {
                                                if (currentUser == null) {
                                                  context.push('/login');
                                                  return;
                                                }
                                                _joinClub(club);
                                              },
                                              style: FilledButton.styleFrom(
                                                backgroundColor:
                                                    AppColors.accentMint,
                                                foregroundColor: Colors.white,
                                                shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(12),
                                                ),
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                  horizontal: 24,
                                                  vertical: 12,
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
                                          else if (club.isPrivate)
                                            Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                horizontal: 12,
                                                vertical: 6,
                                              ),
                                              decoration: BoxDecoration(
                                                color: Colors.black45,
                                                borderRadius:
                                                    BorderRadius.circular(12),
                                              ),
                                              child: Row(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  Icon(
                                                    Icons.lock,
                                                    size: 14,
                                                    color: AppColors.accentMint,
                                                  ),
                                                  const SizedBox(width: 4),
                                                  Text(
                                                    'Private',
                                                    style: TextStyle(
                                                      color:
                                                          AppColors.accentMint,
                                                      fontSize: 12,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            )
                                          else if (isOwner)
                                            Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                horizontal: 12,
                                                vertical: 6,
                                              ),
                                              decoration: BoxDecoration(
                                                gradient: LinearGradient(
                                                  colors: [
                                                    AppColors.accentMint
                                                        .withOpacity(0.2),
                                                    AppColors.accentMint
                                                        .withOpacity(0.4),
                                                  ],
                                                ),
                                                borderRadius:
                                                    BorderRadius.circular(12),
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
                                                      color:
                                                          AppColors.accentMint,
                                                      fontWeight:
                                                          FontWeight.w600,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            )
                                          else if (isMember)
                                            Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                horizontal: 12,
                                                vertical: 6,
                                              ),
                                              decoration: BoxDecoration(
                                                gradient: LinearGradient(
                                                  colors: [
                                                    AppColors.accentMint
                                                        .withOpacity(0.1),
                                                    AppColors.accentMint
                                                        .withOpacity(0.2),
                                                  ],
                                                ),
                                                borderRadius:
                                                    BorderRadius.circular(12),
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
                                                      color:
                                                          AppColors.accentMint,
                                                      fontWeight:
                                                          FontWeight.w500,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                        ],
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    club.description,
                                    style:
                                        Theme.of(context).textTheme.bodyMedium,
                                    maxLines: 3,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 12),
                                  Wrap(
                                    spacing: 8,
                                    runSpacing: 8,
                                    children: [
                                      ...club.genres.take(3).map((genre) {
                                        return Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 8,
                                            vertical: 4,
                                          ),
                                          decoration: BoxDecoration(
                                            color: AppColors.accentMint
                                                .withOpacity(0.1),
                                            borderRadius:
                                                BorderRadius.circular(8),
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
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
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
