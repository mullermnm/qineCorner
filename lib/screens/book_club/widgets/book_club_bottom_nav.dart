import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class BookClubBottomNav extends StatelessWidget {
  final int currentIndex;

  const BookClubBottomNav({
    super.key,
    required this.currentIndex,
  });

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: currentIndex,
      onTap: (index) {
        switch (index) {
          case 0:
            context.go('/book-clubs');
            break;
          case 1:
            context.go('/book-clubs/create');
            break;
          case 2:
            context.go('/book-clubs/my-clubs');
            break;
        }
      },
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.explore),
          label: 'Explore',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.add_circle_outline),
          label: 'Create',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.library_books),
          label: 'My Clubs',
        ),
      ],
    );
  }
}
