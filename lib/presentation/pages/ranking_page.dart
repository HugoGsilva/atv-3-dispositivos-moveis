import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:signals_flutter/signals_flutter.dart';
import '../../di/service_locator.dart';
import '../../domain/models/aluno.dart';
import '../viewmodels/ranking_viewmodel.dart';
import '../theme/app_theme.dart';
import '../widgets/aluno_avatar.dart';

class RankingPage extends StatefulWidget {
  const RankingPage({super.key});

  @override
  State<RankingPage> createState() => _RankingPageState();
}

class _RankingPageState extends State<RankingPage> {
  final _viewModel = serviceLocator<RankingViewModel>();

  @override
  void initState() {
    super.initState();
    _viewModel.calcularCommand.execute();
  }

  Color _corPosicao(int posicao) => switch (posicao) {
    1 => AppColors.gold,
    2 => AppColors.silver,
    3 => AppColors.bronze,
    _ => const Color(0xFF94A3A0),
  };

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Ranking')),
      body: Watch((context) {
        if (_viewModel.calcularCommand.running.value) {
          return const Center(child: CircularProgressIndicator());
        }

        final ranking = _viewModel.ranking.value;
        if (ranking.isEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.leaderboard_rounded,
                    size: 64,
                    color: theme.colorScheme.primary.withValues(alpha: 0.4),
                  ),
                  const SizedBox(height: 16),
                  Text('Ranking vazio', style: theme.textTheme.titleLarge),
                  const SizedBox(height: 6),
                  Text(
                    'Cadastre alunos para disputar o topo do Nível Lenda.',
                    style: theme.textTheme.bodyMedium,
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          );
        }

        final podio = ranking.take(3).toList();
        final restante = ranking.skip(3).toList();

        return ListView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
          children: [
            _Podio(alunos: podio, corPosicao: _corPosicao),
            if (restante.isNotEmpty) ...[
              const SizedBox(height: 24),
              Text('Classificação geral', style: theme.textTheme.titleMedium),
              const SizedBox(height: 8),
              ...List.generate(restante.length, (i) {
                final aluno = restante[i];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: _LinhaRanking(posicao: i + 4, aluno: aluno),
                );
              }),
            ],
          ],
        );
      }),
    );
  }
}

// Pódio dos 3 primeiros (2º à esquerda, 1º ao centro/maior, 3º à direita).
class _Podio extends StatelessWidget {
  final List<Aluno> alunos;
  final Color Function(int) corPosicao;
  const _Podio({required this.alunos, required this.corPosicao});

  @override
  Widget build(BuildContext context) {
    Aluno? at(int i) => i < alunos.length ? alunos[i] : null;
    final primeiro = at(0);
    final segundo = at(1);
    final terceiro = at(2);

    return Container(
      padding: const EdgeInsets.fromLTRB(12, 20, 12, 16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Expanded(child: _coluna(context, segundo, 2, 78)),
          Expanded(child: _coluna(context, primeiro, 1, 104)),
          Expanded(child: _coluna(context, terceiro, 3, 60)),
        ],
      ),
    );
  }

  Widget _coluna(
    BuildContext context,
    Aluno? aluno,
    int posicao,
    double altura,
  ) {
    final theme = Theme.of(context);
    final cor = corPosicao(posicao);

    if (aluno == null) {
      // Espaço reservado quando há menos de 3 alunos.
      return const SizedBox(height: 4);
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (posicao == 1)
          const Icon(
            Icons.workspace_premium_rounded,
            color: AppColors.gold,
            size: 26,
          ),
        const SizedBox(height: 2),
        Stack(
          clipBehavior: Clip.none,
          alignment: Alignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(3),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: cor, width: 2.5),
              ),
              child: AlunoAvatar(
                nome: aluno.nome,
                size: posicao == 1 ? 60 : 48,
              ),
            ),
            Positioned(
              bottom: -8,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 1),
                decoration: BoxDecoration(
                  color: cor,
                  borderRadius: BorderRadius.circular(100),
                ),
                child: Text(
                  '$posicaoº',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Text(
          aluno.apelido.isNotEmpty ? aluno.apelido : aluno.nome,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          textAlign: TextAlign.center,
          style: theme.textTheme.titleMedium?.copyWith(
            fontSize: posicao == 1 ? 15 : 13.5,
          ),
        ),
        const SizedBox(height: 6),
        // Pedestal
        Container(
          height: altura,
          margin: const EdgeInsets.symmetric(horizontal: 4),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                cor.withValues(alpha: 0.85),
                cor.withValues(alpha: 0.45),
              ],
            ),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
          ),
          alignment: Alignment.topCenter,
          padding: const EdgeInsets.only(top: 8),
          child: Column(
            children: [
              Text(
                '${aluno.nivelLenda}',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const Text(
                'pts',
                style: TextStyle(color: Colors.white, fontSize: 10),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// Linha do ranking (4º lugar em diante).
class _LinhaRanking extends StatelessWidget {
  final int posicao;
  final Aluno aluno;
  const _LinhaRanking({required this.posicao, required this.aluno});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      child: InkWell(
        onTap: () => context.push('/aluno/${aluno.id}'),
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              SizedBox(
                width: 28,
                child: Text(
                  '$posicaoº',
                  textAlign: TextAlign.center,
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
              const SizedBox(width: 4),
              AlunoAvatar(nome: aluno.nome, size: 42),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      aluno.apelido.isNotEmpty
                          ? '${aluno.nome} (${aluno.apelido})'
                          : aluno.nome,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontSize: 14,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      '${aluno.curso} • ${aluno.turmaAno}',
                      style: theme.textTheme.bodyMedium?.copyWith(fontSize: 12),
                    ),
                  ],
                ),
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.local_fire_department_rounded,
                    size: 16,
                    color: theme.colorScheme.primary,
                  ),
                  const SizedBox(width: 3),
                  Text(
                    '${aluno.nivelLenda}',
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: theme.colorScheme.primary,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
