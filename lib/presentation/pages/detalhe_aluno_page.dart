import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:signals_flutter/signals_flutter.dart';
import '../../core/constants.dart';
import '../../core/result.dart';
import '../../di/service_locator.dart';
import '../../domain/models/aluno.dart';
import '../viewmodels/detalhe_viewmodel.dart';
import '../widgets/star_rating.dart';
import '../widgets/aluno_avatar.dart';
import '../theme/app_theme.dart';
import '../theme/criterio_icons.dart';

class DetalheAlunoPage extends StatefulWidget {
  final String alunoId;
  const DetalheAlunoPage({super.key, required this.alunoId});

  @override
  State<DetalheAlunoPage> createState() => _DetalheAlunoPageState();
}

class _DetalheAlunoPageState extends State<DetalheAlunoPage> {
  final _viewModel = serviceLocator<DetalheViewModel>();

  @override
  void initState() {
    super.initState();
    _viewModel.carregarCommand.execute(widget.alunoId);
  }

  @override
  Widget build(BuildContext context) {
    return Watch((context) {
      final theme = Theme.of(context);
      final isDark = theme.brightness == Brightness.dark;
      final aluno = _viewModel.aluno.value;

      // Enquanto carrega mostra um spinner; se não encontrar, mensagem.
      if (aluno == null) {
        return Scaffold(
          appBar: AppBar(title: const Text('Detalhes')),
          body: Center(
            child: _viewModel.carregarCommand.running.value
                ? const CircularProgressIndicator()
                : const Text('Aluno não encontrado'),
          ),
        );
      }

      return Scaffold(
        appBar: AppBar(
          title: const Text('Detalhes'),
          actions: [
            IconButton(
              icon: const Icon(Icons.edit_rounded),
              tooltip: 'Editar',
              onPressed: () async {
                await context.push('/cadastro', extra: aluno);
                _viewModel.carregarCommand.execute(widget.alunoId);
              },
            ),
            IconButton(
              icon: const Icon(Icons.delete_outline_rounded),
              tooltip: 'Remover',
              onPressed: () => _confirmarRemocao(aluno),
            ),
            const SizedBox(width: 4),
          ],
        ),
        body: ListView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
          children: [
            Center(
              child: Column(
                children: [
                  AlunoAvatar(nome: aluno.nome, size: 96),
                  const SizedBox(height: 14),
                  Text(
                    aluno.nome,
                    style: theme.textTheme.headlineMedium,
                    textAlign: TextAlign.center,
                  ),
                  if (aluno.apelido.isNotEmpty)
                    Text(
                      '“${aluno.apelido}”',
                      style: theme.textTheme.bodyMedium,
                    ),
                  const SizedBox(height: 14),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    alignment: WrapAlignment.center,
                    children: [
                      _chip(theme, Icons.school_rounded, aluno.curso),
                      _chip(theme, Icons.event_rounded, '${aluno.turmaAno}'),
                      _chip(
                        theme,
                        Icons.cake_rounded,
                        _formatarData(aluno.dataNascimento),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(22),
              decoration: BoxDecoration(
                gradient: isDark
                    ? AppColors.brandGradientDark
                    : AppColors.brandGradient,
                borderRadius: BorderRadius.circular(24),
              ),
              child: Column(
                children: [
                  Text(
                    'NÍVEL LENDA',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.9),
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.5,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      const Icon(
                        Icons.local_fire_department_rounded,
                        color: AppColors.starColor,
                        size: 34,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        '${aluno.nivelLenda}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 52,
                          fontWeight: FontWeight.w800,
                          height: 1,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Text(
                          ' / $kPontuacaoMaxima',
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.7),
                            fontSize: 20,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(100),
                    child: LinearProgressIndicator(
                      value: aluno.nivelLenda / kPontuacaoMaxima,
                      minHeight: 8,
                      backgroundColor: Colors.white.withValues(alpha: 0.22),
                      valueColor: const AlwaysStoppedAnimation<Color>(
                        AppColors.starColor,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),
            Text('Notas por critério', style: theme.textTheme.titleLarge),
            const SizedBox(height: 12),

            for (final criterio in kCriterios)
              _CriterioNota(
                id: criterio['id']!,
                nome: criterio['nome']!,
                nota: aluno.notas[criterio['id']!] ?? kNotaMinima,
              ),
          ],
        ),
      );
    });
  }

  Widget _chip(ThemeData theme, IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(100),
        border: Border.all(color: theme.colorScheme.outlineVariant),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 15, color: theme.colorScheme.primary),
          const SizedBox(width: 5),
          Text(
            label,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurface,
              fontSize: 12.5,
            ),
          ),
        ],
      ),
    );
  }

  String _formatarData(DateTime d) =>
      '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';

  Future<void> _confirmarRemocao(Aluno aluno) async {
    final messenger = ScaffoldMessenger.of(context);
    final nav = GoRouter.of(context);

    final confirmou = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Remover aluno'),
        content: Text('Deseja realmente remover "${aluno.nome}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
            child: const Text('Remover'),
          ),
        ],
      ),
    );

    if (confirmou == true) {
      await _viewModel.removerCommand.execute(aluno.id);
      if (_viewModel.removerCommand.result.value is Success) {
        messenger.showSnackBar(
          SnackBar(content: Text('${aluno.nome} removido')),
        );
        nav.pop();
      }
    }
  }
}

class _CriterioNota extends StatelessWidget {
  final String id;
  final String nome;
  final int nota;
  const _CriterioNota({
    required this.id,
    required this.nome,
    required this.nota,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainer,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: theme.colorScheme.outlineVariant),
      ),
      child: Row(
        children: [
          Icon(
            criterioIcon(id),
            size: 20,
            color: theme.colorScheme.onSurfaceVariant,
          ),
          const SizedBox(width: 10),
          Expanded(child: Text(nome, style: theme.textTheme.bodyLarge)),
          StarRating(rating: nota, readOnly: true, size: 20),
        ],
      ),
    );
  }
}
