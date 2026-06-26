// =============================================================================
// 📝 CADASTRO VIEWMODEL - Controle do Formulário de Cadastro/Edição
// =============================================================================
//
// 🎓 EXPLICAÇÃO PARA APRESENTAÇÃO:
// ---------------------------------
// Este ViewModel controla o formulário de cadastro E edição de alunos.
// Se recebe um aluno existente, entra em modo EDIÇÃO.
// Se não recebe, entra em modo CADASTRO.
//
// Os Signals mantêm cada campo do formulário reativo.
// O Command salvarCommand encapsula a ação de salvar.
// =============================================================================

import 'package:signals_flutter/signals_flutter.dart';
import '../../core/command.dart';
import '../../core/result.dart';
import '../../core/constants.dart';
import '../../domain/models/aluno.dart';
import '../../domain/facades/aluno_facade.dart';

/// ViewModel para cadastro e edição de alunos.
class CadastroViewModel {
  final AlunoFacade _facade;

  // ===========================================================================
  // SIGNALS DO FORMULÁRIO
  // ===========================================================================
  // Cada campo do formulário é um Signal reativo.
  // Quando o usuário digita algo, o signal é atualizado.

  /// Indica se estamos EDITANDO (true) ou CADASTRANDO (false).
  final isEdicao = signal<bool>(false);

  /// ID do aluno sendo editado (null se é cadastro novo).
  final alunoId = signal<String?>(null);

  /// Campo Nome.
  final nome = signal<String>('');

  /// Campo Curso (valor selecionado no Dropdown).
  final curso = signal<String>(kCursosDisponiveis.first);

  /// Campo Turma/Ano.
  final turmaAno = signal<int>(2024);

  /// Campo Apelido.
  final apelido = signal<String>('');

  /// Campo Data de Nascimento.
  final dataNascimento = signal<DateTime>(DateTime(2005, 1, 1));

  /// Notas dos 15 critérios (reativo).
  /// Inicializa todos com nota 1.
  final notas = signal<Map<String, int>>(
    {for (final c in kCriterios) c['id']!: kNotaMinima},
  );

  /// Command para salvar o aluno (cadastrar ou alterar).
  late final Command0<void> salvarCommand;

  CadastroViewModel(this._facade) {
    salvarCommand = Command0<void>(_salvar);
  }

  // ===========================================================================
  // CARREGAR DADOS PARA EDIÇÃO
  // ===========================================================================

  /// Carrega os dados de um aluno existente nos campos do formulário.
  /// Chamado quando entramos em modo de EDIÇÃO.
  void carregarParaEdicao(Aluno aluno) {
    isEdicao.value = true;
    alunoId.value = aluno.id;
    nome.value = aluno.nome;
    curso.value = aluno.curso;
    turmaAno.value = aluno.turmaAno;
    apelido.value = aluno.apelido;
    dataNascimento.value = aluno.dataNascimento;
    notas.value = Map.from(aluno.notas);
  }

  // ===========================================================================
  // ATUALIZAR NOTA DE UM CRITÉRIO
  // ===========================================================================

  /// Atualiza a nota de um critério específico.
  ///
  /// Exemplo: atualizarNota('resenha', 4)
  ///
  /// Precisamos criar um NOVO Map porque Signals só detecta mudanças
  /// quando o valor inteiro muda, não quando um item interno muda.
  void atualizarNota(String criterioId, int nota) {
    final novasNotas = Map<String, int>.from(notas.value);
    novasNotas[criterioId] = nota;
    notas.value = novasNotas; // Atribui um novo Map → Signal detecta a mudança
  }

  // ===========================================================================
  // CALCULAR NÍVEL LENDA EM TEMPO REAL
  // ===========================================================================

  /// Computed signal: calcula o Nível Lenda baseado nas notas atuais.
  /// Atualiza automaticamente quando qualquer nota muda.
  int get nivelLendaAtual =>
      notas.value.values.fold(0, (soma, nota) => soma + nota);

  // ===========================================================================
  // SALVAR (CADASTRAR OU ALTERAR)
  // ===========================================================================

  /// Ação interna do Command: salva o aluno.
  ///
  /// Se isEdicao é true → altera o aluno existente.
  /// Se isEdicao é false → cadastra um novo aluno.
  Future<Result<void>> _salvar() async {
    // Validação
    if (nome.value.trim().isEmpty) {
      return const Failure('O nome do aluno é obrigatório');
    }

    // Normaliza as notas: garante que SEMPRE existam os 15 critérios e que
    // cada valor esteja entre kNotaMinima e kNotaMaxima (1..5). Isso evita
    // persistir um Map incompleto ou com nota fora do intervalo.
    final notasCompletas = <String, int>{
      for (final c in kCriterios)
        c['id']!: (notas.value[c['id']!] ?? kNotaMinima)
            .clamp(kNotaMinima, kNotaMaxima),
    };

    final aluno = Aluno(
      id: alunoId.value, // null = gera novo UUID, não null = mantém o ID
      nome: nome.value.trim(),
      curso: curso.value,
      turmaAno: turmaAno.value,
      apelido: apelido.value.trim(),
      dataNascimento: dataNascimento.value,
      notas: notasCompletas,
    );

    if (isEdicao.value) {
      return await _facade.alterar(aluno);
    } else {
      return await _facade.cadastrar(aluno);
    }
  }

  /// Limpa todos os campos do formulário.
  void limpar() {
    isEdicao.value = false;
    alunoId.value = null;
    nome.value = '';
    curso.value = kCursosDisponiveis.first;
    turmaAno.value = 2024;
    apelido.value = '';
    dataNascimento.value = DateTime(2005, 1, 1);
    notas.value = {for (final c in kCriterios) c['id']!: kNotaMinima};
  }
}
