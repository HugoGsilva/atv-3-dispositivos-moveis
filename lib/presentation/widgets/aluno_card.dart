// =============================================================================
// 🃏 ALUNO CARD - Card do Aluno na Listagem
// =============================================================================
//
// Card resumido de um aluno na Home: avatar, nome/apelido, curso·turma e o
// "Nível Lenda" num selo colorido por faixa de pontuação. Visual flat (borda
// sutil herdada do tema), com hierarquia tipográfica clara.
// =============================================================================

import 'package:flutter/material.dart';
import '../../core/constants.dart';
import '../../domain/models/aluno.dart';
import '../theme/app_theme.dart';
import 'aluno_avatar.dart';

class AlunoCard extends StatelessWidget {
  final Aluno aluno;
  final VoidCallback? onTap;

  const AlunoCard({super.key, required this.aluno, this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cor = _corNivel(aluno.nivelLenda);

    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              AlunoAvatar(nome: aluno.nome, size: 52),
              const SizedBox(width: 14),

              // Nome + curso/turma
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      aluno.nome,
                      style: theme.textTheme.titleMedium,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (aluno.apelido.isNotEmpty)
                      Text(
                        '“${aluno.apelido}”',
                        style: theme.textTheme.bodyMedium?.copyWith(fontSize: 12.5),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        _miniTag(theme, Icons.school_rounded, aluno.curso),
                        const SizedBox(width: 6),
                        _miniTag(theme, Icons.event_rounded, '${aluno.turmaAno}'),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),

              // Selo do Nível Lenda
              _nivelSelo(theme, cor),
            ],
          ),
        ),
      ),
    );
  }

  Widget _nivelSelo(ThemeData theme, Color cor) {
    return Container(
      width: 56,
      padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: cor.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: cor.withValues(alpha: 0.35)),
      ),
      child: Column(
        children: [
          Icon(Icons.local_fire_department_rounded, color: cor, size: 18),
          const SizedBox(height: 2),
          Text(
            '${aluno.nivelLenda}',
            style: TextStyle(color: cor, fontWeight: FontWeight.w800, fontSize: 17),
          ),
          Text(
            'de $kPontuacaoMaxima',
            style: TextStyle(
              color: cor.withValues(alpha: 0.8),
              fontSize: 9,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _miniTag(ThemeData theme, IconData icon, String label) {
    final c = theme.colorScheme.onSurfaceVariant;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 13, color: c),
        const SizedBox(width: 3),
        Text(label, style: theme.textTheme.bodyMedium?.copyWith(fontSize: 12)),
      ],
    );
  }

  /// Cor do selo conforme a faixa de Nível Lenda (dourado no topo → neutro).
  Color _corNivel(int nivel) {
    if (nivel >= 60) return AppColors.gold;           // Lenda
    if (nivel >= 45) return AppColors.primaryLight;   // Esmeralda
    if (nivel >= 30) return AppColors.secondaryLight; // Menta
    return const Color(0xFF94A3A0);                   // Iniciante (neutro)
  }
}
