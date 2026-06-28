import 'package:flutter/material.dart';

/// Retorna o ícone correspondente ao [criterioId] (estrela neutra se desconhecido).
IconData criterioIcon(String criterioId) {
  switch (criterioId) {
    case 'resenha':
      return Icons.celebration_rounded;
    case 'presenca_vip':
      return Icons.visibility_rounded;
    case 'aura':
      return Icons.auto_awesome_rounded;
    case 'modo_parceiro':
      return Icons.handshake_rounded;
    case 'carisma_natural':
      return Icons.volunteer_activism_rounded;
    case 'humor_milhoes':
      return Icons.sentiment_very_satisfied_rounded;
    case 'energia_grupo':
      return Icons.groups_rounded;
    case 'criatividade_caotica':
      return Icons.lightbulb_rounded;
    case 'modo_atleta':
      return Icons.sports_soccer_rounded;
    case 'talento_palco':
      return Icons.mic_external_on_rounded;
    case 'drip_escolar':
      return Icons.checkroom_rounded;
    case 'coracao_dorama':
      return Icons.favorite_rounded;
    case 'queridinho_professores':
      return Icons.school_rounded;
    case 'cerebro_turbo':
      return Icons.psychology_rounded;
    case 'caos_controlado':
      return Icons.bolt_rounded;
    default:
      return Icons.star_rounded;
  }
}
