import 'package:signals_flutter/signals_flutter.dart';
import '../../core/command.dart';
import '../../core/result.dart';
import '../../domain/models/aluno.dart';
import '../../domain/facades/aluno_facade.dart';

/// ViewModel da tela de ranking.
class RankingViewModel {
  final AlunoFacade _facade;

  /// Lista de alunos JÁ ORDENADA por Nível Lenda (maior primeiro).
  final ranking = signal<List<Aluno>>([]);

  /// Command para calcular/recarregar o ranking.
  late final Command0<List<Aluno>> calcularCommand;

  RankingViewModel(this._facade) {
    calcularCommand = Command0<List<Aluno>>(_calcularRanking);
  }

  Future<Result<List<Aluno>>> _calcularRanking() async {
    final resultado = _facade.calcularRanking();

    if (resultado is Success<List<Aluno>>) {
      ranking.value = resultado.value;
    }

    return resultado;
  }
}
