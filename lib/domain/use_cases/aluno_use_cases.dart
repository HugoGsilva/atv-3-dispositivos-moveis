import '../../core/result.dart';
import '../../data/repositories/aluno_repository.dart';
import '../models/aluno.dart';

/// Cadastra um novo aluno no sistema, validando o nome.
class CadastrarAlunoUseCase {
  final AlunoRepository _repository;

  CadastrarAlunoUseCase(this._repository);

  Future<Result<void>> call(Aluno aluno) async {
    if (aluno.nome.trim().isEmpty) {
      return const Failure('O nome do aluno é obrigatório');
    }
    return await _repository.cadastrar(aluno);
  }
}

/// Altera os dados de um aluno existente.
class AlterarAlunoUseCase {
  final AlunoRepository _repository;

  AlterarAlunoUseCase(this._repository);

  Future<Result<void>> call(Aluno aluno) async {
    if (aluno.nome.trim().isEmpty) {
      return const Failure('O nome do aluno é obrigatório');
    }
    return await _repository.alterar(aluno);
  }
}

/// Remove um aluno pelo ID.
class RemoverAlunoUseCase {
  final AlunoRepository _repository;

  RemoverAlunoUseCase(this._repository);

  Future<Result<void>> call(String id) async {
    if (id.isEmpty) {
      return const Failure('ID do aluno é obrigatório');
    }
    return await _repository.remover(id);
  }
}

/// Busca todos os alunos cadastrados.
class BuscarAlunosUseCase {
  final AlunoRepository _repository;

  BuscarAlunosUseCase(this._repository);

  Result<List<Aluno>> call() {
    return _repository.buscarTodos();
  }
}

/// Busca um aluno específico pelo seu ID.
class BuscarAlunoPorIdUseCase {
  final AlunoRepository _repository;

  BuscarAlunoPorIdUseCase(this._repository);

  Result<Aluno> call(String id) {
    return _repository.buscarPorId(id);
  }
}

/// Calcula o ranking dos alunos, ordenando do maior para o menor Nível Lenda.
class CalcularRankingUseCase {
  final AlunoRepository _repository;

  CalcularRankingUseCase(this._repository);

  Result<List<Aluno>> call() {
    final resultado = _repository.buscarTodos();

    switch (resultado) {
      case Success(value: final alunos):
        final ordenados = List<Aluno>.from(alunos)
          ..sort((a, b) => b.nivelLenda.compareTo(a.nivelLenda));
        return Success(ordenados);

      case Failure(message: final msg):
        return Failure(msg);
    }
  }
}
