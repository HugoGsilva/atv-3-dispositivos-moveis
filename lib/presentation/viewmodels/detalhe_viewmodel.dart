import 'package:signals_flutter/signals_flutter.dart';
import '../../core/command.dart';
import '../../core/result.dart';
import '../../domain/models/aluno.dart';
import '../../domain/facades/aluno_facade.dart';

/// ViewModel da tela de detalhes de um aluno.
class DetalheViewModel {
  final AlunoFacade _facade;

  /// Aluno atualmente exibido (null enquanto carrega ou se não encontrado).
  final aluno = signal<Aluno?>(null);

  late final Command1<Aluno, String> carregarCommand;
  late final Command1<void, String> removerCommand;

  DetalheViewModel(this._facade) {
    carregarCommand = Command1<Aluno, String>(_carregar);
    removerCommand = Command1<void, String>(_remover);
  }

  Future<Result<Aluno>> _carregar(String id) async {
    final resultado = _facade.buscarPorId(id);

    if (resultado is Success<Aluno>) {
      aluno.value = resultado.value;
    }

    return resultado;
  }

  Future<Result<void>> _remover(String id) async {
    return await _facade.remover(id);
  }
}
