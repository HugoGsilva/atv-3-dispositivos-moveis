// =============================================================================
// 🟢 ALUNO AVATAR - Avatar reutilizável do aluno
// =============================================================================
//
// Componente único usado na lista, no ranking e no detalhe, para manter o
// MESMO estilo de avatar em todo o app (consistência = design intencional).
// Mostra a inicial do nome sobre o gradiente da marca (verde), com tamanho e
// raio configuráveis e um gradiente alternativo opcional (usado no pódio).
// =============================================================================

import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class AlunoAvatar extends StatelessWidget {
  /// Nome do aluno (usado para extrair a inicial).
  final String nome;

  /// Lado do quadrado do avatar.
  final double size;

  /// Gradiente customizado (ex.: cores do pódio). Se nulo, usa a marca.
  final Gradient? gradient;

  const AlunoAvatar({
    super.key,
    required this.nome,
    this.size = 48,
    this.gradient,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final inicial = nome.trim().isNotEmpty ? nome.trim()[0].toUpperCase() : '?';

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        gradient: gradient ??
            (isDark ? AppColors.brandGradientDark : AppColors.brandGradient),
        borderRadius: BorderRadius.circular(size * 0.3),
      ),
      alignment: Alignment.center,
      child: Text(
        inicial,
        style: TextStyle(
          color: Colors.white,
          fontSize: size * 0.42,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}
