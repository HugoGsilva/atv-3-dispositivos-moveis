// =============================================================================
// ⚙️ USE CASES - Casos de Uso (Camada de Domínio)
// =============================================================================
//
// 🎓 EXPLICAÇÃO PARA APRESENTAÇÃO:
// ---------------------------------
// Use Cases representam as AÇÕES que o sistema pode realizar.
// Cada Use Case faz UMA COISA SÓ (princípio "S" do SOLID).
//
// Pense nos Use Cases como VERBOS do sistema:
//   - CadastrarAlunoUseCase → "cadastrar aluno"
//   - AlterarAlunoUseCase → "alterar aluno"
//   - RemoverAlunoUseCase → "remover aluno"
//   - BuscarAlunosUseCase → "buscar todos os alunos"
//   - BuscarAlunoPorIdUseCase → "buscar aluno por ID"
//   - CalcularRankingUseCase → "calcular ranking"
//
// Use Cases NÃO sabem de onde vêm os dados (SharedPreferences? API? Banco?).
// Eles só usam o Repository.
//
// Use Cases NÃO sabem como a tela funciona.
// Eles só fazem a regra de negócio.
//
// Se amanhã mudarmos de SharedPreferences para Firebase, os Use Cases
// continuam IGUAIS. Isso é Arquitetura Limpa!
//
// O método call() permite usar a classe como se fosse uma função:
//   final resultado = cadastrarUseCase(aluno);  // Em vez de cadastrarUseCase.call(aluno)
// =============================================================================

import '../../core/result.dart';
import '../../data/repositories/aluno_repository.dart';
import '../models/aluno.dart';

/// Cadastra um novo aluno no sistema.
///
/// Valida os dados antes de salvar:
/// - Nome não pode ser vazio
/// - Curso deve estar na lista de cursos válidos
class CadastrarAlunoUseCase {
  final AlunoRepository _repository;

  CadastrarAlunoUseCase(this._repository);

  /// Executa o cadastro do aluno.
  /// O método call() permite usar: cadastrarUseCase(aluno)
  Future<Result<void>> call(Aluno aluno) async {
    // Validação de regra de negócio
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
///
/// Este Use Case contém a REGRA DE NEGÓCIO do ranking:
///   - Busca todos os alunos
///   - Ordena por nivelLenda (descendente: maior primeiro)
///   - Retorna a lista ordenada
class CalcularRankingUseCase {
  final AlunoRepository _repository;

  CalcularRankingUseCase(this._repository);

  Result<List<Aluno>> call() {
    final resultado = _repository.buscarTodos();

    switch (resultado) {
      case Success(value: final alunos):
        // Ordena do MAIOR para o MENOR Nível Lenda
        // b.nivelLenda.compareTo(a.nivelLenda) → descendente
        // Se fosse a.compareTo(b) seria ascendente
        final ordenados = List<Aluno>.from(alunos)
          ..sort((a, b) => b.nivelLenda.compareTo(a.nivelLenda));
        return Success(ordenados);

      case Failure(message: final msg):
        return Failure(msg);
    }
  }
}
