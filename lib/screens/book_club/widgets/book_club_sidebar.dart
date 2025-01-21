import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class BookClubSidebar extends StatelessWidget {
  const BookClubSidebar({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        border: Border(
          right: BorderSide(
            color: Theme.of(context).dividerColor,
          ),
        ),
      ),
      child: ListView(
        padding: const EdgeInsets.symmetric(vertical: 16),
        children: [
          ListTile(
            leading: const Icon(Icons.explore),
            title: const Text('Explore Clubs'),
            selected: GoRouterState.of(context).matchedLocation == '/book-clubs',
            onTap: () => context.go('/book-clubs'),
          ),
          ListTile(
            leading: const Icon(Icons.group),
            title: const Text('My Clubs'),
            selected: GoRouterState.of(context).matchedLocation == '/book-clubs/my-clubs',
            onTap: () => context.go('/book-clubs/my-clubs'),
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.add_circle_outline),
            title: const Text('Create Club'),
            onTap: () => context.push('/book-clubs/create'),
          ),
        ],
      ),
    );
  }
}
