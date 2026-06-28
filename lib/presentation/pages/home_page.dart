import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:signals_flutter/signals_flutter.dart';
import '../../di/service_locator.dart';
import '../../domain/models/aluno.dart';
import '../viewmodels/home_viewmodel.dart';
import '../viewmodels/tema_viewmodel.dart';
import '../widgets/aluno_card.dart';
import '../widgets/aluno_avatar.dart';
import '../theme/app_theme.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final _viewModel = serviceLocator<HomeViewModel>();
  final _temaViewModel = serviceLocator<TemaViewModel>();

  @override
  void initState() {
    super.initState();
    _viewModel.carregarCommand.execute();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pódio da Turma'),
        actions: [
          Watch((context) {
            final dark = _temaViewModel.isDarkMode.value;
            return IconButton(
              icon: Icon(
                dark ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
              ),
              onPressed: () => _temaViewModel.alternarTema(),
              tooltip: dark ? 'Tema claro' : 'Tema escuro',
            );
          }),
          IconButton(
            icon: const Icon(Icons.leaderboard_rounded),
            onPressed: () => context.push('/ranking'),
            tooltip: 'Ranking',
          ),
          IconButton(
            icon: const Icon(Icons.info_outline_rounded),
            onPressed: () => context.push('/sobre'),
            tooltip: 'Sobre o app',
          ),
          const SizedBox(width: 4),
        ],
      ),

      body: Watch((context) {
        if (_viewModel.carregarCommand.running.value) {
          return const Center(child: CircularProgressIndicator());
        }

        final alunos = _viewModel.alunos.value;
        if (alunos.isEmpty) return const _EstadoVazio();

        // Líder atual (maior Nível Lenda) para o destaque do topo.
        final lider = (List<Aluno>.from(
          alunos,
        )..sort((a, b) => b.nivelLenda.compareTo(a.nivelLenda))).first;

        return RefreshIndicator(
          onRefresh: () => _viewModel.carregarCommand.execute(),
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 96),
            children: [
              _Cabecalho(total: alunos.length, lider: lider),
              const SizedBox(height: 16),
              Text(
                'Todos os alunos',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              ...alunos.map(_buildDismissible),
            ],
          ),
        );
      }),

      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          await context.push('/cadastro');
          _viewModel.carregarCommand.execute(); // recarrega ao voltar
        },
        icon: const Icon(Icons.add_rounded),
        label: const Text('Novo Aluno'),
      ),
    );
  }

  Widget _buildDismissible(Aluno aluno) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Dismissible(
        key: Key(aluno.id),
        direction: DismissDirection.endToStart,
        background: Container(
          alignment: Alignment.centerRight,
          padding: const EdgeInsets.only(right: 22),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.errorContainer,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Icon(
            Icons.delete_rounded,
            color: Theme.of(context).colorScheme.onErrorContainer,
          ),
        ),
        confirmDismiss: (_) => _confirmarRemocao(aluno.nome),
        onDismissed: (_) {
          _viewModel.removerCommand.execute(aluno.id);
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('${aluno.nome} removido')));
        },
        child: AlunoCard(
          aluno: aluno,
          onTap: () async {
            await context.push('/aluno/${aluno.id}');
            _viewModel.carregarCommand.execute();
          },
        ),
      ),
    );
  }

  Future<bool?> _confirmarRemocao(String nome) {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Remover aluno'),
        content: Text(
          'Deseja realmente remover "$nome"? Esta ação não pode ser desfeita.',
        ),
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
  }
}

class _Cabecalho extends StatelessWidget {
  final int total;
  final Aluno lider;
  const _Cabecalho({required this.total, required this.lider});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: Theme.of(context).brightness == Brightness.dark
            ? AppColors.brandGradientDark
            : AppColors.brandGradient,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.emoji_events_rounded,
                color: Colors.white,
                size: 18,
              ),
              const SizedBox(width: 6),
              Text(
                'LÍDER ATUAL',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.9),
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.2,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.18),
                  borderRadius: BorderRadius.circular(100),
                ),
                child: Text(
                  '$total ${total == 1 ? 'aluno' : 'alunos'}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              AlunoAvatar(
                nome: lider.nome,
                size: 54,
                gradient: const LinearGradient(
                  colors: [Color(0xFFFFE08A), AppColors.gold],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      lider.nome,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      '${lider.curso} • ${lider.turmaAno}',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.85),
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
              Column(
                children: [
                  Text(
                    '${lider.nivelLenda}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 26,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  Text(
                    'Nível Lenda',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.85),
                      fontSize: 10,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _EstadoVazio extends StatelessWidget {
  const _EstadoVazio();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 96,
              height: 96,
              decoration: BoxDecoration(
                color: theme.colorScheme.primary.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.groups_rounded,
                size: 46,
                color: theme.colorScheme.primary,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Nenhum aluno cadastrado',
              style: theme.textTheme.titleLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 6),
            Text(
              'Toque em "Novo Aluno" para cadastrar o primeiro e começar o ranking.',
              style: theme.textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
