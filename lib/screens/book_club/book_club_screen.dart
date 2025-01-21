import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:qine_corner/common/widgets/loading_animation.dart';
import 'package:qine_corner/core/providers/book_club_provider.dart';
import 'package:qine_corner/core/theme/app_colors.dart';
import 'package:qine_corner/screens/book_club/widgets/book_club_bottom_nav.dart';
import 'package:qine_corner/screens/book_club/widgets/book_club_sidebar.dart';
import 'package:qine_corner/screens/book_club/widgets/popular_clubs_section.dart';
import 'package:qine_corner/screens/book_club/widgets/suggested_clubs_section.dart';

final selectedGenreProvider = StateProvider<String?>((ref) => null);
final searchQueryProvider = StateProvider<String>((ref) => '');

class BookClubScreen extends ConsumerStatefulWidget {
  const BookClubScreen({super.key});

  @override
  ConsumerState<BookClubScreen> createState() => _BookClubScreenState();
}

class _BookClubScreenState extends ConsumerState<BookClubScreen> {
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<String> genres = [
    'Fiction',
    'Non-Fiction',
    'Mystery',
    'Sci-Fi',
    'Romance',
    'Fantasy',
    'Biography',
    'History',
    'Poetry',
    'Self-Help',
  ];

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final popularClubs = ref.watch(popularClubsProvider);
    final suggestedClubs = ref.watch(suggestedClubsProvider);
    final selectedGenre = ref.watch(selectedGenreProvider);
    final searchQuery = ref.watch(searchQueryProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Book Clubs'),
      ),
      body: Row(
        children: [
          // Sidebar - only show on desktop
          if (MediaQuery.of(context).size.width >= 1024)
            const SizedBox(
              width: 250,
              child: BookClubSidebar(),
            ),
          Expanded(
            child: Column(
              children: [
                // Search and Filters
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Search Bar
                      Container(
                        decoration: BoxDecoration(
                          color: isDark ? Colors.grey[800] : Colors.grey[200],
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: TextField(
                          controller: _searchController,
                          onChanged: (value) {
                            ref.read(searchQueryProvider.notifier).state =
                                value;
                          },
                          decoration: InputDecoration(
                            hintText: 'Search for book clubs...',
                            prefixIcon: const Icon(Icons.search),
                            border: InputBorder.none,
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 12,
                            ),
                            suffixIcon: searchQuery.isNotEmpty
                                ? IconButton(
                                    icon: const Icon(Icons.clear),
                                    onPressed: () {
                                      _searchController.clear();
                                      ref
                                          .read(searchQueryProvider.notifier)
                                          .state = '';
                                    },
                                  )
                                : null,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      // Genre Filter
                      SizedBox(
                        height: 40,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: genres.length,
                          itemBuilder: (context, index) {
                            final genre = genres[index];
                            final isSelected = selectedGenre == genre;
                            return Padding(
                              padding: const EdgeInsets.only(right: 8),
                              child: FilterChip(
                                label: Text(genre),
                                selected: isSelected,
                                onSelected: (selected) {
                                  ref
                                      .read(selectedGenreProvider.notifier)
                                      .state = selected ? genre : null;
                                },
                                backgroundColor: isDark
                                    ? Colors.grey[800]
                                    : Colors.grey[200],
                                selectedColor:
                                    AppColors.accentMint.withOpacity(0.2),
                                checkmarkColor: AppColors.accentMint,
                                labelStyle: TextStyle(
                                  color: isSelected
                                      ? AppColors.accentMint
                                      : Theme.of(context)
                                          .textTheme
                                          .bodyLarge
                                          ?.color,
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
                // Club Lists
                Expanded(
                  child: ListView(
                    controller: _scrollController,
                    padding: EdgeInsets.zero,
                    children: [
                      // Popular Clubs Section
                      popularClubs.when(
                        data: (clubs) {
                          final filteredClubs = clubs.where((club) {
                            final matchesSearch = searchQuery.isEmpty ||
                                club.name
                                    .toLowerCase()
                                    .contains(searchQuery.toLowerCase()) ||
                                club.description
                                    .toLowerCase()
                                    .contains(searchQuery.toLowerCase());
                            final matchesGenre = selectedGenre == null ||
                                club.genres.contains(selectedGenre);
                            return matchesSearch && matchesGenre;
                          }).toList();

                          if (filteredClubs.isEmpty) {
                            return const SizedBox();
                          }

                          return PopularClubsSection(clubs: filteredClubs);
                        },
                        loading: () => const Center(child: LoadingAnimation()),
                        error: (error, stack) =>
                            Center(child: Text('Error: $error')),
                      ),
                      const SizedBox(height: 24),
                      // Suggested Clubs Section
                      suggestedClubs.when(
                        data: (clubs) {
                          final filteredClubs = clubs.where((club) {
                            final matchesSearch = searchQuery.isEmpty ||
                                club.name
                                    .toLowerCase()
                                    .contains(searchQuery.toLowerCase()) ||
                                club.description
                                    .toLowerCase()
                                    .contains(searchQuery.toLowerCase());
                            final matchesGenre = selectedGenre == null ||
                                club.genres.contains(selectedGenre);
                            return matchesSearch && matchesGenre;
                          }).toList();

                          if (filteredClubs.isEmpty) {
                            return const SizedBox();
                          }

                          return SuggestedClubsSection(clubs: filteredClubs);
                        },
                        loading: () => const Center(child: LoadingAnimation()),
                        error: (error, stack) =>
                            Center(child: Text('Error: $error')),
                      ),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: MediaQuery.of(context).size.width < 1024
          ? const BookClubBottomNav(currentIndex: 0)
          : null,
    );
  }
}
