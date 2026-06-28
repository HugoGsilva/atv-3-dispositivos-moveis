import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// Widget reutilizável de avaliação por estrelas (1 a 5).
class StarRating extends StatelessWidget {
  final int rating;
  final ValueChanged<int>? onChanged;
  final double size;
  final bool readOnly;

  const StarRating({
    super.key,
    required this.rating,
    this.onChanged,
    this.size = 28,
    this.readOnly = false,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (index) {
        final estrelaNumero = index + 1;

        return GestureDetector(
          onTap: readOnly ? null : () => onChanged?.call(estrelaNumero),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(horizontal: 2),
            child: Icon(
              estrelaNumero <= rating
                  ? Icons.star_rounded
                  : Icons.star_outline_rounded,
              color: estrelaNumero <= rating
                  ? AppColors.starColor
                  : (isDark
                        ? AppColors.starEmptyDark
                        : AppColors.starEmptyLight),
              size: size,
            ),
          ),
        );
      }),
    );
  }
}
