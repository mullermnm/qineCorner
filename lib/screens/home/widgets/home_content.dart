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

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 10),
          CategoriesList(
            onCategorySelected: (category) {
              ref.read(selectedCategoryProvider.notifier).state =
                  category.id == selectedCategoryId ? null : category.id;
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
                    : CategoryBooksList(categoryId: selectedCategoryId),
              ],
            ),
          ),
          if (selectedCategoryId == null) ...[
            const SizedBox(height: 5),
            const BooksGrid(),
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
