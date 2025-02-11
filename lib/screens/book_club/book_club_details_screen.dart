import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:qine_corner/common/widgets/loading_animation.dart';
import 'package:qine_corner/core/models/book_club.dart';
import 'package:qine_corner/core/providers/auth_provider.dart';
import 'package:qine_corner/core/providers/book_club_provider.dart';
import 'package:qine_corner/core/theme/app_colors.dart';
import 'package:qine_corner/screens/book_club/widgets/discussions_tab.dart';
import 'package:qine_corner/screens/book_club/widgets/members_tab.dart';
import 'package:qine_corner/screens/book_club/widgets/reading_schedule_tab.dart';

class BookClubDetailsScreen extends ConsumerStatefulWidget {
  final String clubId;

  const BookClubDetailsScreen({
    super.key,
    required this.clubId,
  });

  @override
  ConsumerState<BookClubDetailsScreen> createState() =>
      _BookClubDetailsScreenState();
}

class _BookClubDetailsScreenState extends ConsumerState<BookClubDetailsScreen> {
  Future<void> _joinClub() async {
    try {
      await ref.read(bookClubProvider.notifier).joinBookClub(widget.clubId);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Successfully joined the club!')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error joining club: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final clubAsync = ref.watch(bookClubDetailsProvider(widget.clubId));
    final club = clubAsync.value;
    final isOwner =
        club?.owner?.id == ref.watch(authNotifierProvider).value?.user?.id;
    final isMember = club!.members.any((member) =>
            member.id == ref.watch(authNotifierProvider).value?.user?.id) ||
        false;

    return clubAsync.when(
      data: (club) {
        if (club == null) {
          return const Center(
            child: Text('Book club not found'),
          );
        }

        return Scaffold(
          body: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Stack(
                  children: [
                    Container(
                      height: 300,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            AppColors.accentMint.withOpacity(0.2),
                            AppColors.accentMint.withOpacity(0.05),
                          ],
                        ),
                      ),
                      child: club.imageUrl != null
                          ? Image.network(
                              club.imageUrl!,
                              fit: BoxFit.cover,
                            )
                          : Center(
                              child: Icon(
                                Icons.menu_book_rounded,
                                size: 64,
                                color: AppColors.accentMint,
                              ),
                            ),
                    ),
                    Positioned(
                      top: 0,
                      left: 0,
                      right: 0,
                      child: SafeArea(
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Row(
                            children: [
                              IconButton(
                                onPressed: () => Navigator.pop(context),
                                icon: const Icon(Icons.arrow_back),
                                style: IconButton.styleFrom(
                                  backgroundColor:
                                      isDark ? Colors.black38 : Colors.white70,
                                  foregroundColor:
                                      isDark ? Colors.white : Colors.black87,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: 0,
                      left: 0,
                      right: 0,
                      child: Container(
                        height: 100,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.transparent,
                              Theme.of(context).scaffoldBackgroundColor,
                            ],
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: 16,
                      left: 16,
                      right: 16,
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
                                      .headlineMedium
                                      ?.copyWith(
                                        fontWeight: FontWeight.bold,
                                        color: isDark
                                            ? Colors.white
                                            : Colors.black87,
                                      ),
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color:
                                      isDark ? Colors.black54 : Colors.white70,
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
                                      '${club.memberCount} Members',
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
                        ],
                      ),
                    ),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'About',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: AppColors.accentMint,
                            ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        club.description,
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Genres',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: AppColors.accentMint,
                            ),
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          ...club.genres.map((genre) {
                            return Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.accentMint.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                genre,
                                style: TextStyle(
                                  color: AppColors.accentMint,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            );
                          }),
                        ],
                      ),
                      const SizedBox(height: 16),
                      if (!club.isPrivate && !isOwner && !isMember)
                        Center(
                          child: ElevatedButton(
                            onPressed: _joinClub,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.accentMint,
                              foregroundColor: Colors.white,
                              minimumSize: const Size(200, 48),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: const [
                                Icon(Icons.add),
                                SizedBox(width: 8),
                                Text('Join Club'),
                              ],
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                DefaultTabController(
                  length: 3,
                  child: Column(
                    children: [
                      TabBar(
                        indicatorColor: AppColors.accentMint,
                        labelColor: AppColors.accentMint,
                        unselectedLabelColor:
                            isDark ? Colors.white60 : Colors.black54,
                        tabs: const [
                          Tab(text: 'Members'),
                          Tab(text: 'Discussions'),
                          Tab(text: 'Schedule'),
                        ],
                      ),
                      SizedBox(
                        height: 500,
                        child: TabBarView(
                          children: [
                            MembersTab(club: club),
                            Stack(
                              children: [
                                DiscussionsTab(clubId: widget.clubId),
                                if (isOwner)
                                  Positioned(
                                    right: 16,
                                    bottom: 16,
                                    child: FloatingActionButton(
                                      onPressed: () => context.push(
                                          '/book-clubs/${widget.clubId}/discussions/create'),
                                      backgroundColor: AppColors.accentMint,
                                      child: const Icon(Icons.add),
                                    ),
                                  ),
                              ],
                            ),
                            Stack(
                              children: [
                                ReadingScheduleTab(clubId: widget.clubId),
                                if (isOwner)
                                  Positioned(
                                    right: 16,
                                    bottom: 16,
                                    child: FloatingActionButton(
                                      onPressed: () => context.push(
                                          '/book-clubs/${widget.clubId}/schedules/create'),
                                      backgroundColor: AppColors.accentMint,
                                      child: const Icon(Icons.add),
                                    ),
                                  ),
                              ],
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
        );
      },
      loading: () => const Center(
        child: LoadingAnimation(),
      ),
      error: (error, stackTrace) => Center(
        child: Text('Error: $error'),
      ),
    );
  }
}
