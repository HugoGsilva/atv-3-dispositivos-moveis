// =============================================================================
// ⭐ STAR RATING - Widget de Avaliação por Estrelas
// =============================================================================
//
// 🎓 EXPLICAÇÃO PARA APRESENTAÇÃO:
// ---------------------------------
// Este é um WIDGET CUSTOMIZADO reutilizável.
// Widgets são os blocos de construção visual do Flutter.
//
// StarRating mostra 5 estrelas clicáveis. Ao tocar em uma estrela,
// a nota é atualizada e o callback onChanged é chamado.
//
// StatelessWidget = widget SEM estado interno.
// Ele recebe tudo de fora (rating, onChanged) e apenas renderiza.
// Quem controla o estado é o ViewModel (princípio MVVM).
// =============================================================================

import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// Widget reutilizável de avaliação por estrelas (1 a 5).
///
/// Parâmetros:
///   - [rating]: nota atual (1-5)
///   - [onChanged]: callback chamado quando o usuário toca em uma estrela
///   - [size]: tamanho de cada estrela (padrão: 28)
///   - [readOnly]: se true, as estrelas não são clicáveis
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
        final estrelaNumero = index + 1; // 1, 2, 3, 4, 5

        return GestureDetector(
          // Só é clicável se não for readOnly
          onTap: readOnly ? null : () => onChanged?.call(estrelaNumero),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(horizontal: 2),
            child: Icon(
              // Se a nota atual >= número da estrela → estrela preenchida
              // Senão → estrela vazia
              estrelaNumero <= rating ? Icons.star_rounded : Icons.star_outline_rounded,
              color: estrelaNumero <= rating
                  ? AppColors.starColor
                  : (isDark ? AppColors.starEmptyDark : AppColors.starEmptyLight),
              size: size,
            ),
          ),
        );
      }),
    );
  }
}
