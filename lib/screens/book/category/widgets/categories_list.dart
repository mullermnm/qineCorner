import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qine_corner/common/widgets/loading_animation.dart';
import 'package:qine_corner/core/theme/app_colors.dart';
import '../../../../core/models/category.dart';
import '../../../../core/providers/categories_provider.dart';
import 'category_chip.dart';

class CategoriesList extends ConsumerWidget {
  final Function(Category) onCategorySelected;
  final String? selectedCategoryId;

  const CategoriesList({
    super.key,
    required this.onCategorySelected,
    this.selectedCategoryId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categoriesAsync = ref.watch(categoriesProvider);

    return categoriesAsync.when(
      data: (categories) {
        if (categories.isEmpty) {
          return const Center(
            child: Text('No categories found'),
          );
        }

        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: categories.map((category) {
                final isSelected = category.id == selectedCategoryId;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: CategoryChip(
                    category: category,
                    isSelected: isSelected,
                    onTap: () => onCategorySelected(category),
                  ),
                );
              }).toList(),
            ),
          ),
        );
      },
      loading: () => const Center(
        child: LoadingAnimation(),
      ),
      error: (error, stackTrace) => Center(
        child: Text('Error: $error'),
      ),
    );
  }
}
