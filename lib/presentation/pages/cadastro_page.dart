// =============================================================================
// 📝 CADASTRO PAGE - Tela de Cadastro/Edição de Aluno
// =============================================================================
//
// 🎓 EXPLICAÇÃO PARA APRESENTAÇÃO:
// ---------------------------------
// Formulário de cadastro E edição (controlado pelo CadastroViewModel).
//   - TextFormField → nome, apelido (digitação)
//   - DropdownButtonFormField → curso, turma/ano (seleção)
//   - showDatePicker → data de nascimento
//   - StarRating → cada um dos 15 critérios
// A ação de salvar é disparada pelo salvarCommand (padrão Command).
//
// Design: campos agrupados em "seções" com cabeçalho, resumo do Nível Lenda em
// tempo real com barra de progresso, e cada critério com seu próprio ícone.
// =============================================================================

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:signals_flutter/signals_flutter.dart';
import '../../core/constants.dart';
import '../../core/result.dart';
import '../../di/service_locator.dart';
import '../../domain/models/aluno.dart';
import '../viewmodels/cadastro_viewmodel.dart';
import '../widgets/star_rating.dart';
import '../theme/criterio_icons.dart';

class CadastroPage extends StatefulWidget {
  /// Aluno a ser editado (null = modo cadastro).
  final Aluno? alunoParaEditar;

  const CadastroPage({super.key, this.alunoParaEditar});

  @override
  State<CadastroPage> createState() => _CadastroPageState();
}

class _CadastroPageState extends State<CadastroPage> {
  final _formKey = GlobalKey<FormState>();
  final _viewModel = serviceLocator<CadastroViewModel>();

  late final TextEditingController _nomeController;
  late final TextEditingController _apelidoController;

  @override
  void initState() {
    super.initState();
    if (widget.alunoParaEditar != null) {
      _viewModel.carregarParaEdicao(widget.alunoParaEditar!);
    } else {
      _viewModel.limpar();
    }
    _nomeController = TextEditingController(text: _viewModel.nome.value);
    _apelidoController = TextEditingController(text: _viewModel.apelido.value);
  }

  @override
  void dispose() {
    _nomeController.dispose();
    _apelidoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Watch((context) =>
            Text(_viewModel.isEdicao.value ? 'Editar Aluno' : 'Novo Aluno')),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
          children: [
            // ---- Seção: Dados cadastrais -------------------------------------
            _SectionHeader(icon: Icons.badge_rounded, titulo: 'Dados cadastrais'),
            const SizedBox(height: 12),
            _card(
              theme,
              child: Column(
                children: [
                  TextFormField(
                    controller: _nomeController,
                    textCapitalization: TextCapitalization.words,
                    decoration: const InputDecoration(
                      labelText: 'Nome *',
                      prefixIcon: Icon(Icons.person_rounded),
                      hintText: 'Nome completo do aluno',
                    ),
                    validator: (v) => (v == null || v.trim().isEmpty)
                        ? 'O nome é obrigatório'
                        : null,
                    onChanged: (v) => _viewModel.nome.value = v,
                  ),
                  const SizedBox(height: 14),
                  TextFormField(
                    controller: _apelidoController,
                    decoration: const InputDecoration(
                      labelText: 'Apelido',
                      prefixIcon: Icon(Icons.tag_rounded),
                      hintText: 'Opcional',
                    ),
                    onChanged: (v) => _viewModel.apelido.value = v,
                  ),
                  const SizedBox(height: 14),
                  Watch((context) => DropdownButtonFormField<String>(
                        initialValue: _viewModel.curso.value,
                        decoration: const InputDecoration(
                          labelText: 'Curso *',
                          prefixIcon: Icon(Icons.school_rounded),
                        ),
                        items: [
                          for (final c in kCursosDisponiveis)
                            DropdownMenuItem(value: c, child: Text(c)),
                        ],
                        onChanged: (v) {
                          if (v != null) _viewModel.curso.value = v;
                        },
                      )),
                  const SizedBox(height: 14),
                  Watch((context) => DropdownButtonFormField<int>(
                        initialValue: _viewModel.turmaAno.value,
                        decoration: const InputDecoration(
                          labelText: 'Turma/Ano *',
                          prefixIcon: Icon(Icons.event_rounded),
                        ),
                        items: [
                          for (final ano in kTurmaAnosDisponiveis.reversed)
                            DropdownMenuItem(value: ano, child: Text('$ano')),
                        ],
                        onChanged: (v) {
                          if (v != null) _viewModel.turmaAno.value = v;
                        },
                      )),
                  const SizedBox(height: 14),
                  Watch((context) {
                    final d = _viewModel.dataNascimento.value;
                    return InkWell(
                      onTap: () => _selecionarData(context),
                      borderRadius: BorderRadius.circular(16),
                      child: InputDecorator(
                        decoration: const InputDecoration(
                          labelText: 'Data de Nascimento *',
                          prefixIcon: Icon(Icons.cake_rounded),
                        ),
                        child: Text(_formatarData(d),
                            style: theme.textTheme.bodyLarge),
                      ),
                    );
                  }),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // ---- Resumo do Nível Lenda (tempo real) --------------------------
            Watch((context) => _ResumoNivel(nivel: _viewModel.nivelLendaAtual)),

            const SizedBox(height: 20),

            // ---- Seção: Critérios -------------------------------------------
            _SectionHeader(
                icon: Icons.star_rounded,
                titulo: 'Critérios de popularidade',
                subtitulo: 'Avalie cada item de 1 a 5 estrelas'),
            const SizedBox(height: 12),

            Watch((context) {
              final notas = _viewModel.notas.value;
              return Column(
                children: [
                  for (final criterio in kCriterios)
                    _CriterioTile(
                      id: criterio['id']!,
                      nome: criterio['nome']!,
                      descricao: criterio['descricao']!,
                      nota: notas[criterio['id']!] ?? kNotaMinima,
                      onChanged: (n) =>
                          _viewModel.atualizarNota(criterio['id']!, n),
                    ),
                ],
              );
            }),

            const SizedBox(height: 24),

            // ---- Botão salvar -----------------------------------------------
            Watch((context) {
              final loading = _viewModel.salvarCommand.running.value;
              return SizedBox(
                height: 54,
                child: ElevatedButton.icon(
                  onPressed: loading ? null : _salvar,
                  icon: loading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                              strokeWidth: 2, color: Colors.white),
                        )
                      : const Icon(Icons.check_rounded),
                  label: Text(_viewModel.isEdicao.value
                      ? 'Salvar alterações'
                      : 'Cadastrar aluno'),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _card(ThemeData theme, {required Widget child}) {
    return Card(child: Padding(padding: const EdgeInsets.all(16), child: child));
  }

  String _formatarData(DateTime d) =>
      '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';

  Future<void> _selecionarData(BuildContext context) async {
    final escolhida = await showDatePicker(
      context: context,
      initialDate: _viewModel.dataNascimento.value,
      firstDate: DateTime(1950),
      lastDate: DateTime.now(),
      helpText: 'Selecione a data de nascimento',
    );
    if (escolhida != null) _viewModel.dataNascimento.value = escolhida;
  }

  Future<void> _salvar() async {
    if (!_formKey.currentState!.validate()) return;

    await _viewModel.salvarCommand.execute();
    if (!mounted) return;

    final resultado = _viewModel.salvarCommand.result.value;
    final messenger = ScaffoldMessenger.of(context);

    if (resultado is Success) {
      messenger.showSnackBar(SnackBar(
        content: Text(_viewModel.isEdicao.value
            ? 'Aluno atualizado com sucesso!'
            : 'Aluno cadastrado com sucesso!'),
      ));
      context.pop();
    } else if (resultado is Failure) {
      messenger.showSnackBar(SnackBar(
        content: Text(resultado.message),
        backgroundColor: Theme.of(context).colorScheme.error,
      ));
    }
  }
}

// =============================================================================
// Componentes visuais privados
// =============================================================================

class _SectionHeader extends StatelessWidget {
  final IconData icon;
  final String titulo;
  final String? subtitulo;
  const _SectionHeader(
      {required this.icon, required this.titulo, this.subtitulo});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: theme.colorScheme.primary, size: 20),
        const SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(titulo, style: theme.textTheme.titleLarge),
            if (subtitulo != null)
              Text(subtitulo!, style: theme.textTheme.bodyMedium),
          ],
        ),
      ],
    );
  }
}

class _ResumoNivel extends StatelessWidget {
  final int nivel;
  const _ResumoNivel({required this.nivel});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final progresso = (nivel - kPontuacaoMinima) /
        (kPontuacaoMaxima - kPontuacaoMinima); // 0..1
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.primaryContainer,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Icon(Icons.local_fire_department_rounded,
                  color: theme.colorScheme.onPrimaryContainer),
              const SizedBox(width: 8),
              Text('Nível Lenda',
                  style: theme.textTheme.titleMedium?.copyWith(
                      color: theme.colorScheme.onPrimaryContainer)),
              const Spacer(),
              Text('$nivel / $kPontuacaoMaxima',
                  style: theme.textTheme.titleLarge?.copyWith(
                      color: theme.colorScheme.onPrimaryContainer)),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(100),
            child: LinearProgressIndicator(
              value: progresso.clamp(0.0, 1.0),
              minHeight: 8,
              backgroundColor:
                  theme.colorScheme.onPrimaryContainer.withValues(alpha: 0.15),
              valueColor:
                  AlwaysStoppedAnimation<Color>(theme.colorScheme.primary),
            ),
          ),
        ],
      ),
    );
  }
}

class _CriterioTile extends StatelessWidget {
  final String id;
  final String nome;
  final String descricao;
  final int nota;
  final ValueChanged<int> onChanged;

  const _CriterioTile({
    required this.id,
    required this.nome,
    required this.descricao,
    required this.nota,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainer,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: theme.colorScheme.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(criterioIcon(id),
                    size: 20, color: theme.colorScheme.primary),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(nome, style: theme.textTheme.titleMedium),
                    Text(descricao,
                        style: theme.textTheme.bodyMedium?.copyWith(fontSize: 11.5),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Center(
            child: StarRating(rating: nota, onChanged: onChanged, size: 34),
          ),
        ],
      ),
    );
  }
}
