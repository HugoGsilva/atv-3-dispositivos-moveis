// =============================================================================
// 🎭 FACADE - Fachada de Use Cases (Camada de Domínio)
// =============================================================================
//
// 🎓 EXPLICAÇÃO PARA APRESENTAÇÃO:
// ---------------------------------
// A Facade (Fachada) é um padrão de projeto que SIMPLIFICA o acesso
// a um conjunto de funcionalidades complexas.
//
// SEM Facade (ruim):
//   A ViewModel precisaria conhecer 6 Use Cases diferentes:
//   - cadastrarUseCase, alterarUseCase, removerUseCase,
//   - buscarTodosUseCase, buscarPorIdUseCase, calcularRankingUseCase
//
// COM Facade (bom):
//   A ViewModel conhece APENAS a Facade:
//   - facade.cadastrar(aluno)
//   - facade.alterar(aluno)
//   - facade.remover(id)
//   - facade.buscarTodos()
//   - facade.buscarPorId(id)
//   - facade.calcularRanking()
//
// Analogia: A Facade é como a RECEPÇÃO de um hospital.
//   Você não precisa saber onde fica cada médico.
//   Fala com a recepcionista e ela te direciona.
//   A ViewModel é o paciente, os Use Cases são os médicos.
// =============================================================================

import '../../core/result.dart';
import '../models/aluno.dart';
import '../use_cases/aluno_use_cases.dart';

/// Fachada que agrupa todos os Use Cases relacionados a Aluno.
///
/// A ViewModel deve interagir APENAS com esta Facade,
/// sem conhecer os Use Cases individuais.
class AlunoFacade {
  final CadastrarAlunoUseCase _cadastrar;
  final AlterarAlunoUseCase _alterar;
  final RemoverAlunoUseCase _remover;
  final BuscarAlunosUseCase _buscarTodos;
  final BuscarAlunoPorIdUseCase _buscarPorId;
  final CalcularRankingUseCase _calcularRanking;

  AlunoFacade({
    required CadastrarAlunoUseCase cadastrar,
    required AlterarAlunoUseCase alterar,
    required RemoverAlunoUseCase remover,
    required BuscarAlunosUseCase buscarTodos,
    required BuscarAlunoPorIdUseCase buscarPorId,
    required CalcularRankingUseCase calcularRanking,
  })  : _cadastrar = cadastrar,
        _alterar = alterar,
        _remover = remover,
        _buscarTodos = buscarTodos,
        _buscarPorId = buscarPorId,
        _calcularRanking = calcularRanking;

  /// Cadastra um novo aluno.
  Future<Result<void>> cadastrar(Aluno aluno) => _cadastrar(aluno);

  /// Altera um aluno existente.
  Future<Result<void>> alterar(Aluno aluno) => _alterar(aluno);

  /// Remove um aluno pelo ID.
  Future<Result<void>> remover(String id) => _remover(id);

  /// Busca todos os alunos cadastrados.
  Result<List<Aluno>> buscarTodos() => _buscarTodos();

  /// Busca um aluno pelo ID.
  Result<Aluno> buscarPorId(String id) => _buscarPorId(id);

  /// Retorna a lista de alunos ordenada por Nível Lenda (ranking).
  Result<List<Aluno>> calcularRanking() => _calcularRanking();
}
