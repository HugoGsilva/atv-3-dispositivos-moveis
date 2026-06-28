import 'package:signals_flutter/signals_flutter.dart';
import '../../core/command.dart';
import '../../core/result.dart';
import '../../domain/models/aluno.dart';
import '../../domain/facades/aluno_facade.dart';

/// ViewModel da tela principal (lista de alunos).
class HomeViewModel {
  final AlunoFacade _facade;

  final alunos = signal<List<Aluno>>([]);

  late final Command0<List<Aluno>> carregarCommand;
  late final Command1<void, String> removerCommand;

  HomeViewModel(this._facade) {
    carregarCommand = Command0<List<Aluno>>(_carregarAlunos);
    removerCommand = Command1<void, String>(_removerAluno);
  }

  Future<Result<List<Aluno>>> _carregarAlunos() async {
    final resultado = _facade.buscarTodos();

    if (resultado is Success<List<Aluno>>) {
      alunos.value = resultado.value;
    }

    return resultado;
  }

  Future<Result<void>> _removerAluno(String id) async {
    final resultado = await _facade.remover(id);

    if (resultado is Success) {
      await _carregarAlunos();
    }

    return resultado;
  }
}
