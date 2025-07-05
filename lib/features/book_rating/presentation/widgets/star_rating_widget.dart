import 'package:flutter/material.dart';

class StarRatingWidget extends StatelessWidget {
  final double rating;
  final double size;
  final bool interactive;
  final ValueChanged<double>? onRatingChanged;
  final Color? activeColor;
  final Color? inactiveColor;

  const StarRatingWidget({
    Key? key,
    required this.rating,
    this.size = 24.0,
    this.interactive = false,
    this.onRatingChanged,
    this.activeColor,
    this.inactiveColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final activeStarColor = activeColor ?? theme.colorScheme.primary;
    final inactiveStarColor = inactiveColor ?? theme.colorScheme.onSurface.withOpacity(0.3);

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (index) {
        final value = index + 1;
        final isActive = value <= rating;
        final isHalf = value == rating.ceil() && rating % 1 != 0;

        return GestureDetector(
          onTap: interactive ? () => onRatingChanged?.call(value.toDouble()) : null,
          child: Icon(
            isHalf ? Icons.star_half : (isActive ? Icons.star : Icons.star_border),
            color: isActive || isHalf ? activeStarColor : inactiveStarColor,
            size: size,
          ),
        );
      }),
    );
  }
}
