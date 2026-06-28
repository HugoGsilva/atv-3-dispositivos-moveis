import 'dart:convert';
import '../../core/result.dart';
import '../../core/constants.dart';
import '../../domain/models/aluno.dart';
import '../services/shared_preferences_service.dart';

/// Gerencia a persistência dos alunos, convertendo entre [Aluno] e JSON.
class AlunoRepository {
  final SharedPreferencesService _service;

  AlunoRepository(this._service);

  Result<List<Aluno>> buscarTodos() {
    try {
      final jsonString = _service.getString(kChaveAlunos);

      // Lista modificável (growable): cadastrar/alterar/remover fazem add/
      // removeWhere; uma lista const lançaria "Cannot add to an unmodifiable list".
      if (jsonString == null || jsonString.isEmpty) {
        return Success(<Aluno>[]);
      }

      final List<dynamic> jsonList = jsonDecode(jsonString);

      final alunos = jsonList
          .map((json) => Aluno.fromJson(json as Map<String, dynamic>))
          .toList();

      return Success(alunos);
    } catch (e) {
      return Failure('Erro ao buscar alunos: $e');
    }
  }

  /// Busca um aluno específico pelo seu ID.
  Result<Aluno> buscarPorId(String id) {
    try {
      final resultado = buscarTodos();

      switch (resultado) {
        case Success(value: final alunos):
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

  /// Salva a lista completa de alunos. Usado por cadastrar, alterar e remover.
  Future<Result<void>> _salvarTodos(List<Aluno> alunos) async {
    try {
      final jsonList = alunos.map((a) => a.toJson()).toList();
      final jsonString = jsonEncode(jsonList);
      await _service.saveString(kChaveAlunos, jsonString);

      return const Success(null);
    } catch (e) {
      return Failure('Erro ao salvar alunos: $e');
    }
  }

  /// Cadastra um novo aluno no sistema.
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

  /// Altera os dados de um aluno existente.
  Future<Result<void>> alterar(Aluno alunoAtualizado) async {
    try {
      final resultado = buscarTodos();

      switch (resultado) {
        case Success(value: final alunos):
          final index = alunos.indexWhere((a) => a.id == alunoAtualizado.id);

          if (index == -1) {
            return const Failure('Aluno não encontrado para alteração');
          }

          alunos[index] = alunoAtualizado;
          return await _salvarTodos(alunos);

        case Failure(message: final msg):
          return Failure(msg);
      }
    } catch (e) {
      return Failure('Erro ao alterar aluno: $e');
    }
  }

  /// Remove um aluno pelo seu ID.
  Future<Result<void>> remover(String id) async {
    try {
      final resultado = buscarTodos();

      switch (resultado) {
        case Success(value: final alunos):
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
