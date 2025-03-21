import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qine_corner/core/providers/books_provider.dart';
import 'package:qine_corner/core/services/search_service.dart';
import 'package:qine_corner/core/widgets/streak_card.dart';
import 'package:qine_corner/screens/home/widgets/search_results.dart';
import 'widgets/sliver_search_app_bar.dart';
import 'widgets/home_content.dart';
import 'widgets/note_rewind_card.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    final searchResults = ref.watch(booksProvider).searchResults;
    final showSearchResults = _searchQuery.isNotEmpty;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) {
          return [
            SliverPersistentHeader(
              delegate: SliverSearchAppBar(
                context: context,
                onSearchChanged: (query) {
                  setState(() {
                    _searchQuery = query;
                  });
                  
                  // Actually perform the search
                  if (query.isNotEmpty) {
                    // Debounce the search to avoid too many API calls
                    Future.delayed(const Duration(milliseconds: 300), () {
                      if (query == _searchQuery) { // Only search if query hasn't changed
                        ref.read(booksProvider.notifier).searchBooks(query);
                      }
                    });
                  }
                },
              ),
              pinned: true,
            ),
          ];
        },
        body: showSearchResults
            ? SearchResults(
                query: _searchQuery,
                results: searchResults,
                onResultSelected: () {
                  setState(() {
                    _searchQuery = '';
                  });
                },
              )
            : CustomScrollView(
                slivers: [
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        children: [
                          StreakCard(),
                          NoteRewindCard(),
                          SizedBox(height: 16),
                          HomeContent(),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}
