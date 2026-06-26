// =============================================================================
// 📦 REPOSITORY - Repositório de Alunos (Camada de Dados)
// =============================================================================
//
// 🎓 EXPLICAÇÃO PARA APRESENTAÇÃO:
// ---------------------------------
// O Repository é o INTERMEDIÁRIO entre os dados brutos (JSON/String) e
// os objetos do domínio (Aluno).
//
// Se o Service é o "funcionário do estoque", o Repository é o GERENTE:
//   - Ele pede ao funcionário (Service) para buscar os dados
//   - Ele CONVERTE os dados brutos em objetos úteis (String → Aluno)
//   - Ele entrega os objetos prontos para quem pediu (Use Cases)
//
// Fluxo de SALVAR:
//   List<Aluno> → toJson() cada um → jsonEncode toda a lista → Service.saveString()
//
// Fluxo de LER:
//   Service.getString() → jsonDecode → fromJson() cada um → List<Aluno>
//
// O Repository usa Result<T> para retornar sucesso ou erro de forma segura.
//
// 🔑 PRINCÍPIO SOLID APLICADO:
//   - "D" (Dependency Inversion): O Repository recebe o Service pelo
//     construtor, não cria ele mesmo. Isso facilita testes e troca.
// =============================================================================

import 'dart:convert'; // Para jsonEncode e jsonDecode
import '../../core/result.dart';
import '../../core/constants.dart';
import '../../domain/models/aluno.dart';
import '../services/shared_preferences_service.dart';

/// Repositório responsável por gerenciar a persistência dos alunos.
///
/// Converte entre objetos [Aluno] e JSON/String para armazenamento.
/// Usa [SharedPreferencesService] para acessar o armazenamento local.
class AlunoRepository {
  /// Dependência injetada pelo construtor (Dependency Inversion).
  /// O Repository não cria o Service — ele RECEBE de fora.
  final SharedPreferencesService _service;

  AlunoRepository(this._service);

  // ===========================================================================
  // BUSCAR TODOS OS ALUNOS
  // ===========================================================================

  /// Busca todos os alunos salvos no SharedPreferences.
  ///
  /// Retorno:
  ///   - `Success(List<Aluno>)` → lista de alunos (pode ser vazia)
  ///   - Failure(mensagem) → se ocorrer erro na leitura/conversão
  Result<List<Aluno>> buscarTodos() {
    try {
      // 1. Busca a String JSON do SharedPreferences
      final jsonString = _service.getString(kChaveAlunos);

      // 2. Se não existe dados salvos, retorna lista vazia (sucesso!)
      //    IMPORTANTE: retornamos uma lista MODIFICÁVEL (growable), e não
      //    `const []`. Os métodos cadastrar/alterar/remover fazem .add()/
      //    .removeWhere() sobre esta lista — uma lista const é imutável e
      //    lançaria "Cannot add to an unmodifiable list" ao cadastrar o
      //    PRIMEIRO aluno (quando ainda não há nada salvo).
      if (jsonString == null || jsonString.isEmpty) {
        return Success(<Aluno>[]);
      }

      // 3. Decodifica o JSON String para uma List de Maps
      //    "[{...}, {...}]" → [Map, Map]
      final List<dynamic> jsonList = jsonDecode(jsonString);

      // 4. Converte cada Map para um objeto Aluno
      //    [Map, Map] → [Aluno, Aluno]
      final alunos = jsonList
          .map((json) => Aluno.fromJson(json as Map<String, dynamic>))
          .toList();

      return Success(alunos);
    } catch (e) {
      return Failure('Erro ao buscar alunos: $e');
    }
  }

  // ===========================================================================
  // BUSCAR ALUNO POR ID
  // ===========================================================================

  /// Busca um aluno específico pelo seu ID.
  ///
  /// Retorno:
  ///   - Success(Aluno) → aluno encontrado
  ///   - Failure(mensagem) → aluno não encontrado ou erro
  Result<Aluno> buscarPorId(String id) {
    try {
      final resultado = buscarTodos();

      // Pattern matching: verifica se buscarTodos() deu certo
      switch (resultado) {
        case Success(value: final alunos):
          // .firstWhere() procura o primeiro aluno com o ID informado
          // orElse retorna null se não encontrar
          final aluno = alunos.cast<Aluno?>().firstWhere(
                (a) => a!.id == id,
                orElse: () => null,
              );
          if (aluno != null) {
            return Success(aluno);
          }
          return const Failure('Aluno não encontrado');

        case Failure(message: final msg):
          return Failure(msg);
      }
    } catch (e) {
      return Failure('Erro ao buscar aluno: $e');
    }
  }

  // ===========================================================================
  // SALVAR LISTA DE ALUNOS
  // ===========================================================================

  /// Salva a lista completa de alunos no SharedPreferences.
  ///
  /// Este é um método interno usado por cadastrar, alterar e remover.
  /// Converte: `List<Aluno>` → `List<Map>` → JSON String → SharedPreferences
  Future<Result<void>> _salvarTodos(List<Aluno> alunos) async {
    try {
      // 1. Converte cada Aluno para Map
      final jsonList = alunos.map((a) => a.toJson()).toList();

      // 2. Converte a lista de Maps para JSON String
      final jsonString = jsonEncode(jsonList);

      // 3. Salva no SharedPreferences
      await _service.saveString(kChaveAlunos, jsonString);

      return const Success(null);
    } catch (e) {
      return Failure('Erro ao salvar alunos: $e');
    }
  }

  // ===========================================================================
  // CADASTRAR ALUNO
  // ===========================================================================

  /// Cadastra um novo aluno no sistema.
  ///
  /// Fluxo:
  /// 1. Busca todos os alunos existentes
  /// 2. Adiciona o novo aluno à lista
  /// 3. Salva a lista completa atualizada
  Future<Result<void>> cadastrar(Aluno aluno) async {
    try {
      final resultado = buscarTodos();

      switch (resultado) {
        case Success(value: final alunos):
          alunos.add(aluno);
          return await _salvarTodos(alunos);

        case Failure(message: final msg):
          return Failure(msg);
      }
    } catch (e) {
      return Failure('Erro ao cadastrar aluno: $e');
    }
  }

  // ===========================================================================
  // ALTERAR ALUNO
  // ===========================================================================

  /// Altera os dados de um aluno existente.
  ///
  /// Fluxo:
  /// 1. Busca todos os alunos
  /// 2. Encontra o aluno pelo ID
  /// 3. Substitui o aluno antigo pelo atualizado
  /// 4. Salva a lista completa
  Future<Result<void>> alterar(Aluno alunoAtualizado) async {
    try {
      final resultado = buscarTodos();

      switch (resultado) {
        case Success(value: final alunos):
          // Encontra o índice do aluno a ser atualizado
          final index = alunos.indexWhere((a) => a.id == alunoAtualizado.id);

          if (index == -1) {
            return const Failure('Aluno não encontrado para alteração');
          }

          // Substitui o aluno no índice encontrado
          alunos[index] = alunoAtualizado;
          return await _salvarTodos(alunos);

        case Failure(message: final msg):
          return Failure(msg);
      }
    } catch (e) {
      return Failure('Erro ao alterar aluno: $e');
    }
  }

  // ===========================================================================
  // REMOVER ALUNO
  // ===========================================================================

  /// Remove um aluno pelo seu ID.
  ///
  /// Fluxo:
  /// 1. Busca todos os alunos
  /// 2. Remove o aluno com o ID informado
  /// 3. Salva a lista atualizada (sem o aluno removido)
  Future<Result<void>> remover(String id) async {
    try {
      final resultado = buscarTodos();

      switch (resultado) {
        case Success(value: final alunos):
          // removeWhere remove todos que satisfazem a condição
          alunos.removeWhere((a) => a.id == id);
          return await _salvarTodos(alunos);

        case Failure(message: final msg):
          return Failure(msg);
      }
    } catch (e) {
      return Failure('Erro ao remover aluno: $e');
    }
  }
}
