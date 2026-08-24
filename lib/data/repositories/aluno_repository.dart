import 'package:sqflite/sqflite.dart';
import '../../core/result.dart';
import '../../domain/models/aluno.dart';
import '../services/database_service.dart';

/// Gerencia a persistência dos alunos no SQLite, convertendo entre [Aluno] e
/// as tabelas normalizadas `alunos` (dados cadastrais) e `notas` (uma linha
/// por critério).
class AlunoRepository {
  final DatabaseService _service;

  AlunoRepository(this._service);

  Database get _db => _service.db;

  /// Converte uma linha da tabela `alunos` + suas notas em um [Aluno].
  Aluno _fromRow(Map<String, Object?> row, Map<String, int> notas) {
    return Aluno(
      id: row['id'] as String,
      nome: row['nome'] as String,
      curso: row['curso'] as String,
      turmaAno: row['turma_ano'] as int,
      apelido: row['apelido'] as String? ?? '',
      dataNascimento: DateTime.parse(row['data_nascimento'] as String),
      notas: notas,
    );
  }

  /// Colunas da tabela `alunos` a partir de um [Aluno] (sem as notas).
  Map<String, Object?> _toRow(Aluno aluno) {
    return {
      'id': aluno.id,
      'nome': aluno.nome,
      'curso': aluno.curso,
      'turma_ano': aluno.turmaAno,
      'apelido': aluno.apelido,
      'data_nascimento': aluno.dataNascimento.toIso8601String(),
    };
  }

  /// Insere as 15 notas de um aluno dentro de uma transação [txn].
  Future<void> _inserirNotas(Transaction txn, Aluno aluno) async {
    final batch = txn.batch();
    aluno.notas.forEach((criterioId, nota) {
      batch.insert('notas', {
        'aluno_id': aluno.id,
        'criterio_id': criterioId,
        'nota': nota,
      });
    });
    await batch.commit(noResult: true);
  }

  Future<Result<List<Aluno>>> buscarTodos() async {
    try {
      final linhasAlunos = await _db.query('alunos');
      final linhasNotas = await _db.query('notas');

      // Agrupa as notas por aluno_id para remontar o Map de cada aluno.
      final notasPorAluno = <String, Map<String, int>>{};
      for (final n in linhasNotas) {
        final alunoId = n['aluno_id'] as String;
        notasPorAluno.putIfAbsent(alunoId, () => {})[n['criterio_id']
            as String] = n['nota'] as int;
      }

      final alunos = linhasAlunos
          .map((row) => _fromRow(row, notasPorAluno[row['id']] ?? {}))
          .toList();

      return Success(alunos);
    } catch (e) {
      return Failure('Erro ao buscar alunos: $e');
    }
  }

  /// Busca um aluno específico pelo seu ID.
  Future<Result<Aluno>> buscarPorId(String id) async {
    try {
      final linhas = await _db.query(
        'alunos',
        where: 'id = ?',
        whereArgs: [id],
        limit: 1,
      );
      if (linhas.isEmpty) {
        return const Failure('Aluno não encontrado');
      }

      final linhasNotas = await _db.query(
        'notas',
        where: 'aluno_id = ?',
        whereArgs: [id],
      );
      final notas = <String, int>{
        for (final n in linhasNotas)
          n['criterio_id'] as String: n['nota'] as int,
      };

      return Success(_fromRow(linhas.first, notas));
    } catch (e) {
      return Failure('Erro ao buscar aluno: $e');
    }
  }

  /// Cadastra um novo aluno: insere na tabela `alunos` e suas 15 notas,
  /// tudo em uma única transação.
  Future<Result<void>> cadastrar(Aluno aluno) async {
    try {
      await _db.transaction((txn) async {
        await txn.insert('alunos', _toRow(aluno));
        await _inserirNotas(txn, aluno);
      });
      return const Success(null);
    } catch (e) {
      return Failure('Erro ao cadastrar aluno: $e');
    }
  }

  /// Altera os dados de um aluno existente. Atualiza a linha em `alunos` e
  /// regrava todas as notas (delete + insert) dentro de uma transação.
  Future<Result<void>> alterar(Aluno alunoAtualizado) async {
    try {
      final afetadas = await _db.transaction((txn) async {
        final linhas = await txn.update(
          'alunos',
          _toRow(alunoAtualizado),
          where: 'id = ?',
          whereArgs: [alunoAtualizado.id],
        );
        if (linhas == 0) return 0;

        await txn.delete(
          'notas',
          where: 'aluno_id = ?',
          whereArgs: [alunoAtualizado.id],
        );
        await _inserirNotas(txn, alunoAtualizado);
        return linhas;
      });

      if (afetadas == 0) {
        return const Failure('Aluno não encontrado para alteração');
      }
      return const Success(null);
    } catch (e) {
      return Failure('Erro ao alterar aluno: $e');
    }
  }

  /// Remove um aluno pelo seu ID. As notas somem via ON DELETE CASCADE.
  Future<Result<void>> remover(String id) async {
    try {
      await _db.delete('alunos', where: 'id = ?', whereArgs: [id]);
      return const Success(null);
    } catch (e) {
      return Failure('Erro ao remover aluno: $e');
    }
  }
}
