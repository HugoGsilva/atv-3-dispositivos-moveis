// =============================================================================
// 🏠 HOME VIEWMODEL - Controle da Tela Principal
// =============================================================================
//
// 🎓 EXPLICAÇÃO PARA APRESENTAÇÃO:
// ---------------------------------
// O ViewModel é o "CÉREBRO" de cada tela. Ele:
//   1. Mantém o ESTADO da tela (lista de alunos, loading, erros)
//   2. Executa AÇÕES via Commands (carregar, remover)
//   3. Comunica-se com a Facade para acessar as regras de negócio
//
// A tela (UI) NÃO faz lógica. Ela apenas:
//   - OBSERVA os signals do ViewModel
//   - DISPARA commands quando o usuário clica em algo
//
// Flutter Signals torna tudo REATIVO:
//   - Quando alunos.value muda → a lista na tela se atualiza sozinha
//   - Quando carregarCommand.running.value é true → mostra loading spinner
//
// O ViewModel NÃO conhece widgets. Ele poderia ser usado com qualquer UI.
// =============================================================================

import 'package:signals_flutter/signals_flutter.dart';
import '../../core/command.dart';
import '../../core/result.dart';
import '../../domain/models/aluno.dart';
import '../../domain/facades/aluno_facade.dart';

/// ViewModel da tela principal (lista de alunos).
class HomeViewModel {
  final AlunoFacade _facade;

  /// Signal reativo com a lista de alunos.
  /// Quando este valor muda, toda UI observando ele se reconstrói.
  final alunos = signal<List<Aluno>>([]);

  /// Command para carregar todos os alunos.
  /// Encapsula: loading state + resultado + erro.
  late final Command0<List<Aluno>> carregarCommand;

  /// Command para remover um aluno (recebe o ID como parâmetro).
  late final Command1<void, String> removerCommand;

  HomeViewModel(this._facade) {
    // Inicializa os Commands com as ações correspondentes
    carregarCommand = Command0<List<Aluno>>(_carregarAlunos);
    removerCommand = Command1<void, String>(_removerAluno);
  }

  /// Ação interna: carrega todos os alunos da Facade.
  Future<Result<List<Aluno>>> _carregarAlunos() async {
    final resultado = _facade.buscarTodos();

    // Se deu certo, atualiza o signal (que atualiza a UI)
    if (resultado is Success<List<Aluno>>) {
      alunos.value = resultado.value;
    }

    return resultado;
  }

  /// Ação interna: remove um aluno e recarrega a lista.
  Future<Result<void>> _removerAluno(String id) async {
    final resultado = await _facade.remover(id);

    // Após remover, recarrega a lista para atualizar a UI
    if (resultado is Success) {
      await _carregarAlunos();
    }

    return resultado;
  }
}
