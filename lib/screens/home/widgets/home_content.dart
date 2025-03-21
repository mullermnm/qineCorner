import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../common/widgets/app_text.dart';
import '../../../core/models/category.dart';
import '../../../core/services/category_service.dart';
import '../../book/category/widgets/categories_list.dart';
import '../../book/widgets/books_grid.dart';
import '../../book/widgets/category_books_list.dart';
import '../../book/widgets/favorites_widget.dart';
import '../../book/widgets/recent_books.dart';

final selectedCategoryProvider = StateProvider<String?>((ref) => null);

class HomeContent extends ConsumerWidget {
  const HomeContent({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedCategoryId = ref.watch(selectedCategoryProvider);

    String getCategoryTitle(String categoryId) {
      switch (categoryId) {
        case 'fiction':
          return 'Fiction Books';
        case 'non-fiction':
          return 'Non-Fiction Books';
        case 'science':
          return 'Science & Technology';
        case 'business':
          return 'Business & Economics';
        case 'children':
          return 'Children\'s Books';
        default:
          return categoryId.split('-').map((word) => 
            word[0].toUpperCase() + word.substring(1)
          ).join(' ');
      }
    }

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 10),
          CategoriesList(
            onCategorySelected: (category) {
              ref.read(selectedCategoryProvider.notifier).state =
                  (category.id == selectedCategoryId ? null : category.id)
                      as String?;
            },
            selectedCategoryId: selectedCategoryId,
          ),
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppText.h2(
                  selectedCategoryId == null
                      ? 'Recent Books'
                      : 'Books in Category',
                ),
                const SizedBox(height: 10),
                selectedCategoryId == null
                    ? const RecentBooks()
                    : CategoryBooksList(
                        categoryId: selectedCategoryId,
                        // title: getCategoryTitle(selectedCategoryId),
                      ),
              ],
            ),
          ),
          if (selectedCategoryId == null) ...[
            const SizedBox(height: 5),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10.0),
              child: AppText.h2('Popular Books'),
            ),
            const SizedBox(height: 10),
            const SizedBox(
              height: 600, // Fixed height for grid
              child: BooksGrid(),
            ),
            const SizedBox(height: 10),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 10.0),
              child: SizedBox(
                height: 400,
                child: FavoritesWidget(),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
