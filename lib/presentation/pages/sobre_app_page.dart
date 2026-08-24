import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class SobreAppPage extends StatelessWidget {
  const SobreAppPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(title: const Text('Sobre o App')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 90,
                height: 90,
                decoration: BoxDecoration(
                  gradient: isDark
                      ? AppColors.primaryGradientDark
                      : AppColors.primaryGradientLight,
                  borderRadius: BorderRadius.circular(24),
                ),
                child: const Icon(
                  Icons.emoji_events_rounded,
                  size: 48,
                  color: Colors.amber,
                ),
              ),
            ),
            const SizedBox(height: 16),
            Center(
              child: Text(
                'Pirâmide da Popularidade — IFPR-Pguá',
                style: theme.textTheme.headlineMedium,
                textAlign: TextAlign.center,
              ),
            ),
            Center(
              child: Text(
                'Ranking de Popularidade dos Alunos',
                style: theme.textTheme.bodyMedium,
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 32),

            _buildSection(
              context,
              icon: Icons.info_outline_rounded,
              title: 'Objetivo',
              content:
                  'O Ranking de Popularidade dos Alunos é um aplicativo desenvolvido em Flutter para fins didáticos. Ele permite cadastrar alunos do IFPR – Campus Paranaguá e avaliá-los em critérios descontraídos de convivência, destaque e participação na turma.',
            ),
            const SizedBox(height: 20),

            _buildSection(
              context,
              icon: Icons.school_rounded,
              title: 'Contexto',
              content:
                  'O aplicativo foi desenvolvido no contexto do IFPR – Campus Paranaguá, para a disciplina de Dispositivos Móveis. Os alunos cadastrados estão vinculados aos cursos ofertados no campus (INFO, MEC, MAMB, PROD, TADS, TGA).',
            ),
            const SizedBox(height: 20),

            _buildSection(
              context,
              icon: Icons.star_rounded,
              title: 'Critérios de Avaliação',
              content:
                  'Cada aluno recebe notas de 1 a 5 estrelas em 15 categorias descontraídas, como Resenha, Aura, Carisma Natural, Humor de Milhões, Drip Escolar, entre outros.',
            ),
            const SizedBox(height: 20),

            _buildSection(
              context,
              icon: Icons.calculate_rounded,
              title: 'Nível Lenda',
              content:
                  'A soma dessas notas forma o Nível Lenda, usado para organizar o ranking geral. A pontuação varia de 15 (mínimo) a 75 (máximo) pontos.',
            ),
            const SizedBox(height: 20),

            _buildSection(
              context,
              icon: Icons.phone_android_rounded,
              title: 'Armazenamento',
              content:
                  'Todos os dados são armazenados localmente no dispositivo em um banco de dados SQLite. Nenhum dado é enviado para servidores externos.',
            ),
            const SizedBox(height: 20),

            _buildSection(
              context,
              icon: Icons.dark_mode_rounded,
              title: 'Temas',
              content:
                  'O aplicativo permite alternar entre tema claro e tema escuro a qualquer momento, para melhor conforto visual.',
            ),
            const SizedBox(height: 40),

            Center(
              child: Text(
                'Desenvolvido para fins didáticos • IFPR Paranaguá',
                style: theme.textTheme.bodyMedium?.copyWith(fontSize: 12),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  /// Constrói uma seção com ícone, título e texto.
  Widget _buildSection(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String content,
  }) {
    final theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: theme.colorScheme.primary, size: 22),
                const SizedBox(width: 10),
                Text(title, style: theme.textTheme.titleLarge),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              content,
              style: theme.textTheme.bodyLarge?.copyWith(height: 1.5),
            ),
          ],
        ),
      ),
    );
  }
}
