import 'package:signals_flutter/signals_flutter.dart';
import '../../core/command.dart';
import '../../core/result.dart';
import '../../core/constants.dart';
import '../../domain/models/aluno.dart';
import '../../domain/facades/aluno_facade.dart';

/// ViewModel para cadastro e edição de alunos.
class CadastroViewModel {
  final AlunoFacade _facade;

  /// Indica se estamos editando (true) ou cadastrando (false).
  final isEdicao = signal<bool>(false);

  /// ID do aluno sendo editado (null se é cadastro novo).
  final alunoId = signal<String?>(null);

  final nome = signal<String>('');
  final curso = signal<String>(kCursosDisponiveis.first);
  final turmaAno = signal<int>(2024);
  final apelido = signal<String>('');
  final dataNascimento = signal<DateTime>(DateTime(2005, 1, 1));

  /// Notas dos 15 critérios, inicializadas com a nota mínima.
  final notas = signal<Map<String, int>>({
    for (final c in kCriterios) c['id']!: kNotaMinima,
  });

  late final Command0<void> salvarCommand;

  CadastroViewModel(this._facade) {
    salvarCommand = Command0<void>(_salvar);
  }

  /// Carrega os dados de um aluno existente nos campos do formulário.
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

  /// Atualiza a nota de um critério.
  void atualizarNota(String criterioId, int nota) {
    // Cria um novo Map: o Signal só detecta troca da referência inteira.
    final novasNotas = Map<String, int>.from(notas.value);
    novasNotas[criterioId] = nota;
    notas.value = novasNotas;
  }

  /// Nível Lenda calculado a partir das notas atuais.
  int get nivelLendaAtual =>
      notas.value.values.fold(0, (soma, nota) => soma + nota);

  Future<Result<void>> _salvar() async {
    if (nome.value.trim().isEmpty) {
      return const Failure('O nome do aluno é obrigatório');
    }

    // Normaliza: garante os 15 critérios com valor entre kNotaMinima e kNotaMaxima.
    final notasCompletas = <String, int>{
      for (final c in kCriterios)
        c['id']!: (notas.value[c['id']!] ?? kNotaMinima).clamp(
          kNotaMinima,
          kNotaMaxima,
        ),
    };

    final aluno = Aluno(
      id: alunoId.value, // null gera novo UUID; caso contrário mantém o ID
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
