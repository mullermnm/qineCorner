import 'package:flutter/material.dart';
import 'package:qine_corner/core/services/search_service.dart';
import 'widgets/sliver_search_app_bar.dart';
import 'widgets/home_content.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final SearchService _searchService = SearchService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) {
          return [
            SliverPersistentHeader(
              delegate:
                  SliverSearchAppBar(onSearch: _searchService.handleSearch),
              pinned: true,
            ),
          ];
        },
        body: const HomeContent(),
      ),
    );
  }
}
