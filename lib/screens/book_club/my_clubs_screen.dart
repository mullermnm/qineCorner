import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:qine_corner/common/widgets/loading_animation.dart';
import 'package:qine_corner/core/providers/book_club_provider.dart';
import 'package:qine_corner/screens/book_club/widgets/book_club_bottom_nav.dart';
import 'package:qine_corner/screens/error/widgets/animated_error_widget.dart';

class MyClubsScreen extends ConsumerStatefulWidget {
  const MyClubsScreen({super.key});

  @override
  ConsumerState<MyClubsScreen> createState() => _MyClubsScreenState();
}

class _MyClubsScreenState extends ConsumerState<MyClubsScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Book Clubs'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => context.push('/book-clubs/create'),
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Admin'),
            Tab(text: 'Member'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _AdminClubsTab(),
          _MemberClubsTab(),
        ],
      ),
      bottomNavigationBar: const BookClubBottomNav(currentIndex: 2),
    );
  }
}

class _AdminClubsTab extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final clubsAsync = ref.watch(myAdminClubsProvider);

    return clubsAsync.when(
      data: (clubs) {
        if (clubs.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'No clubs created yet',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => context.push('/book-clubs/create'),
                  child: const Text('Create a Book Club'),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: clubs.length,
          itemBuilder: (context, index) {
            final club = clubs[index];
            return Card(
              margin: const EdgeInsets.only(bottom: 16),
              child: ListTile(
                onTap: () => context.push('/book-clubs/${club.id}'),
                leading: CircleAvatar(
                  backgroundImage: club.imageUrl != null
                      ? NetworkImage(club.imageUrl!)
                      : null,
                  child: club.imageUrl == null
                      ? Icon(
                          Icons.menu_book_rounded,
                          color: Theme.of(context).colorScheme.primary,
                        )
                      : null,
                ),
                title: Text(
                  club.name,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                subtitle: Text(
                  '${club.memberCount} Members · ${club.genres.join(", ")}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                trailing: const Icon(Icons.chevron_right),
              ),
            );
          },
        );
      },
      loading: () => const LoadingAnimation(),
      error: (error, stack) => AnimatedErrorWidget(
        message: error.toString(),
        onRetry: () => ref.refresh(myAdminClubsProvider),
      ),
    );
  }
}

class _MemberClubsTab extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final clubsAsync = ref.watch(myMemberClubsProvider);

    return clubsAsync.when(
      data: (clubs) {
        if (clubs.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Not a member of any clubs yet',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => context.push('/book-clubs'),
                  child: const Text('Explore Book Clubs'),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: clubs.length,
          itemBuilder: (context, index) {
            final club = clubs[index];
            return Card(
              margin: const EdgeInsets.only(bottom: 16),
              child: ListTile(
                onTap: () => context.push('/book-clubs/${club.id}'),
                leading: CircleAvatar(
                  backgroundImage: club.imageUrl != null
                      ? NetworkImage(club.imageUrl!)
                      : null,
                  child: club.imageUrl == null
                      ? Icon(
                          Icons.menu_book_rounded,
                          color: Theme.of(context).colorScheme.primary,
                        )
                      : null,
                ),
                title: Text(
                  club.name,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                subtitle: Text(
                  '${club.memberCount} Members · ${club.genres.join(", ")}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                trailing: const Icon(Icons.chevron_right),
              ),
            );
          },
        );
      },
      loading: () => const LoadingAnimation(),
      error: (error, stack) => AnimatedErrorWidget(
        message: error.toString(),
        onRetry: () => ref.refresh(myMemberClubsProvider),
      ),
    );
  }
}
