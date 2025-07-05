import 'package:flutter/material.dart';
import '../../../../core/models/category.dart';
import '../../../../core/theme/app_colors.dart';

class CategoryChip extends StatelessWidget {
  final Category category;
  final bool isSelected;
  final VoidCallback onTap;

  const CategoryChip({
    super.key,
    required this.category,
    required this.isSelected,
    required this.onTap,
  });

  IconData _getIconData(String? iconName) {
    switch (iconName?.toLowerCase()) {
      case 'person':
        return Icons.person;
      case 'church':
        return Icons.church;
      case 'novel':
        return Icons.book;
      case 'heart':
        return Icons.favorite;
      case 'books':
        return Icons.library_books;
      case 'baby':
        return Icons.child_care;
      case 'microscope':
        return Icons.science;
      case 'castle':
        return Icons.castle;
      case 'school':
        return Icons.school;
      default:
        return Icons.book;
    }
  }

  Color _getIconColor(String? iconName) {
    switch (iconName?.toLowerCase()) {
      case 'person':
        return Colors.deepPurple;
      case 'church':
        return Colors.brown;
      case 'books':
        return Colors.green;
      case 'baby':
        return Colors.pink;
      case 'microscope':
        return Colors.blue;
      case 'castle':
        return Colors.orange;
      case 'school':
        return Colors.teal;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final iconColor = _getIconColor(category.icon);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Ink(
          decoration: BoxDecoration(
            color: isSelected
                ? iconColor.withOpacity(0.2)
                : (isDark
                    ? AppColors.darkSurfaceBackground
                    : AppColors.lightSurfaceBackground),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isSelected
                  ? iconColor
                  : (isDark
                      ? AppColors.darkTextSecondary.withOpacity(0.2)
                      : AppColors.lightTextSecondary.withOpacity(0.2)),
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 8,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  _getIconData(category.icon),
                  size: 20,
                  color: isSelected
                      ? iconColor
                      : (isDark
                          ? AppColors.darkTextPrimary
                          : AppColors.lightTextPrimary),
                ),
                const SizedBox(width: 8),
                Text(
                  category.name,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    color: isSelected
                        ? iconColor
                        : (isDark
                            ? AppColors.darkTextPrimary
                            : AppColors.lightTextPrimary),
                  ),
                ),
                if (category.booksCount != null && category.booksCount! > 0) ...[
                  const SizedBox(width: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: iconColor.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      category.booksCount.toString(),
                      style: TextStyle(
                        fontSize: 12,
                        color: iconColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
