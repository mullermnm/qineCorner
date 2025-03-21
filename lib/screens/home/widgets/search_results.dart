import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:qine_corner/core/config/app_config.dart';
import 'package:qine_corner/core/models/book.dart';
import 'package:qine_corner/core/models/category.dart';
import 'package:qine_corner/core/providers/auth_provider.dart';
import 'package:qine_corner/screens/auth/verification_screen.dart';

class SearchResults extends StatelessWidget {
  final String query;
  final List<Book> results;
  final VoidCallback? onResultSelected;

  const SearchResults({
    Key? key,
    required this.query,
    required this.results,
    this.onResultSelected,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (context, ref, child) {
        final authState = ref.watch(authNotifierProvider);
        return authState.when(
          data: (state) {
            if (state == null || !state.token.isNotEmpty) {
              return const Center(
                child: Text('Please login to view search results'),
              );
            }
            if (!state.isVerified) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                        'Please verify your phone number to view search results'),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => VerificationScreen(
                              userId: state.userId!,
                              phone: state.phone!,
                            ),
                          ),
                        );
                      },
                      child: const Text('Verify Now'),
                    ),
                  ],
                ),
              );
            }
            return _buildSearchResults(context);
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, _) => Center(child: Text('Error: $error')),
        );
      },
    );
  }

  Widget _buildSearchResults(BuildContext context) {
    if (results.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.search_off,
              size: 64,
              color: Colors.grey,
            ),
            const SizedBox(height: 16),
            Text(
              'No results found for "$query"',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Colors.grey,
                  ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () {
                context.push('/book-request', extra: query);
              },
              icon: const Icon(Icons.add_circle_outline),
              label: const Text('Request This Book'),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: results.length,
      itemBuilder: (context, index) {
        final book = results[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: ListTile(
            contentPadding: const EdgeInsets.all(16),
            leading: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network(
                AppConfig.getAssetUrl(book.coverUrl),
                width: 60,
                height: 90,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    width: 60,
                    height: 90,
                    color: Colors.grey[200],
                    child: const Icon(Icons.book),
                  );
                },
              ),
            ),
            title: Text(
              book.title,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 4),
                Text(
                  book.author.name,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.grey[600],
                      ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(
                      Icons.star,
                      size: 16,
                      color: Colors.amber[600],
                    ),
                    const SizedBox(width: 4),
                    Text(
                      book.rating?.toStringAsFixed(1) ?? '0.0',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    const SizedBox(width: 16),
                    if (book.categories.isNotEmpty)
                      Expanded(
                        child: SizedBox(
                          height: 24,
                          child: ListView.separated(
                            scrollDirection: Axis.horizontal,
                            itemCount: book.categories.length > 2 ? 2 : book.categories.length,
                            separatorBuilder: (context, index) => const SizedBox(width: 4),
                            itemBuilder: (context, index) {
                              final category = book.categories[index];
                              return _buildCategoryChip(context, category);
                            },
                          ),
                        ),
                      ),
                  ],
                ),
              ],
            ),
            onTap: () {
              context.push('/book/${book.id}', extra: book);
              onResultSelected?.call();
            },
          ),
        );
      },
    );
  }

  Widget _buildCategoryChip(BuildContext context, dynamic category) {
    // Extract category information
    String name;
    String icon = 'category';
    
    if (category is Map) {
      name = category['name']?.toString() ?? 'Unknown';
      icon = category['icon']?.toString() ?? 'category';
    } else if (category is Category) {
      name = category.name;
      icon = category.icon ?? 'category';
    } else {
      name = category.toString();
    }
    
    // Get color and icon
    IconData iconData = _getCategoryIcon(icon);
    Color color = _getCategoryColor(name);
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(iconData, size: 12, color: color),
          const SizedBox(width: 4),
          Text(
            name,
            style: TextStyle(fontSize: 10, color: color, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }

  String _getCategoryName(dynamic category) {
    if (category is Map) {
      return category['name']?.toString() ?? 'Unknown';
    }
    return category.toString();
  }

  IconData _getCategoryIcon(String category) {
    switch (category.toLowerCase()) {
      case 'fiction': return Icons.auto_stories;
      case 'fantasy': return Icons.casino;
      case 'mystery': return Icons.search;
      case 'romance': return Icons.favorite;
      case 'thriller': return Icons.psychology;
      case 'horror': return Icons.dangerous;
      case 'sci-fi': return Icons.rocket;
      case 'science fiction': return Icons.rocket;
      case 'biography': return Icons.person;
      case 'history': return Icons.history_edu;
      default: return Icons.category;
    }
  }

  Color _getCategoryColor(String category) {
    switch (category.toLowerCase()) {
      case 'fiction': return Colors.blue;
      case 'fantasy': return Colors.purple;
      case 'mystery': return Colors.amber;
      case 'romance': return Colors.pink;
      case 'thriller': return Colors.red;
      case 'horror': return Colors.deepOrange;
      case 'sci-fi': return Colors.indigo;
      case 'science fiction': return Colors.indigo;
      case 'biography': return Colors.teal;
      case 'history': return Colors.brown;
      default: return Colors.grey;
    }
  }
}
