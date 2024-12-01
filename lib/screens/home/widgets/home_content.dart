import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../common/widgets/app_text.dart';
import '../../../core/models/category.dart';
import '../../../core/services/category_service.dart';
import '../../book/category/widgets/categories_list.dart';
import '../../book/widgets/books_grid.dart';
import '../../book/widgets/category_books_list.dart';
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
          const SizedBox(height: 16),
          CategoriesList(
            onCategorySelected: (category) {
              ref.read(selectedCategoryProvider.notifier).state =
                  category.id == selectedCategoryId ? null : category.id;
            },
            selectedCategoryId: selectedCategoryId,
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppText.h2(
                  selectedCategoryId == null
                      ? 'Popular Books'
                      : 'Books in Category',
                ),
                const SizedBox(height: 16),
                selectedCategoryId == null
                    ? const BooksGrid()
                    : CategoryBooksList(categoryId: selectedCategoryId),
              ],
            ),
          ),
          if (selectedCategoryId == null) ...[
            const SizedBox(height: 24),
            const RecentBooks(),
          ],
        ],
      ),
    );
  }
}
