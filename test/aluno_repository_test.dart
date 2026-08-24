import 'package:flutter_test/flutter_test.dart';
import 'package:piramid_game/core/constants.dart';
import 'package:piramid_game/core/result.dart';
import 'package:piramid_game/data/repositories/aluno_repository.dart';
import 'package:piramid_game/data/services/database_service.dart';
import 'package:piramid_game/domain/models/aluno.dart';

import 'helpers/db_util.dart';

Aluno _aluno({
  String? id,
  String nome = 'Teste',
  String curso = 'INFO',
  int turmaAno = 2024,
  Map<String, int>? notas,
}) {
  return Aluno(
    id: id,
    nome: nome,
    curso: curso,
    turmaAno: turmaAno,
    dataNascimento: DateTime(2005, 1, 1),
    notas: notas,
  );
}

void main() {
  late DatabaseService service;
  late AlunoRepository repo;

  setUp(() async {
    service = await criarDatabaseServiceEmMemoria();
    repo = AlunoRepository(service);
  });

  tearDown(() async {
    await service.close();
  });

  Future<List<Aluno>> todos() async =>
      (await repo.buscarTodos() as Success<List<Aluno>>).value;

  group('AlunoRepository', () {
    test('buscarTodos retorna lista vazia quando não há dados', () async {
      final r = await repo.buscarTodos();
      expect(r, isA<Success<List<Aluno>>>());
      expect((r as Success<List<Aluno>>).value, isEmpty);
    });

    test('cadastrar persiste o aluno e buscarTodos o retorna', () async {
      final r = await repo.cadastrar(_aluno(nome: 'Ana'));
      expect(r, isA<Success>());

      final lista = await todos();
      expect(lista.length, 1);
      expect(lista.first.nome, 'Ana');
    });

    test('cadastrar persiste as 15 notas normalizadas', () async {
      await repo.cadastrar(
        _aluno(nome: 'Notas', notas: {for (final c in kCriterios) c['id']!: 3}),
      );

      final salvo = (await todos()).first;
      expect(salvo.notas.length, 15);
      expect(salvo.notas.values.every((n) => n == 3), isTrue);
    });

    test('cadastrar vários acumula (não sobrescreve)', () async {
      await repo.cadastrar(_aluno(nome: 'A'));
      await repo.cadastrar(_aluno(nome: 'B'));
      await repo.cadastrar(_aluno(nome: 'C'));

      final lista = await todos();
      expect(lista.map((a) => a.nome), containsAll(['A', 'B', 'C']));
      expect(lista.length, 3);
    });

    test('buscarPorId encontra o aluno certo', () async {
      await repo.cadastrar(_aluno(id: 'id-1', nome: 'Um'));
      await repo.cadastrar(_aluno(id: 'id-2', nome: 'Dois'));

      final r = await repo.buscarPorId('id-2');
      expect(r, isA<Success<Aluno>>());
      expect((r as Success<Aluno>).value.nome, 'Dois');
    });

    test('buscarPorId retorna Failure quando o id não existe', () async {
      final r = await repo.buscarPorId('inexistente');
      expect(r, isA<Failure>());
      expect((r as Failure).message, contains('não encontrado'));
    });

    test('alterar substitui os dados e as notas do aluno pelo id', () async {
      await repo.cadastrar(
        _aluno(id: 'id-x', nome: 'Antigo', notas: {for (final c in kCriterios) c['id']!: 1}),
      );

      final atualizado = _aluno(
        id: 'id-x',
        nome: 'Novo',
        curso: 'TADS',
        notas: {for (final c in kCriterios) c['id']!: 5},
      );
      final r = await repo.alterar(atualizado);
      expect(r, isA<Success>());

      final encontrado = (await repo.buscarPorId('id-x') as Success<Aluno>).value;
      expect(encontrado.nome, 'Novo');
      expect(encontrado.curso, 'TADS');
      expect(encontrado.notas.values.every((n) => n == 5), isTrue);
    });

    test('alterar retorna Failure quando o id não existe', () async {
      final r = await repo.alterar(_aluno(id: 'nao-existe'));
      expect(r, isA<Failure>());
    });

    test('remover exclui o aluno e suas notas (cascade)', () async {
      await repo.cadastrar(_aluno(id: 'manter', nome: 'Fica'));
      await repo.cadastrar(_aluno(id: 'apagar', nome: 'Sai'));

      final r = await repo.remover('apagar');
      expect(r, isA<Success>());

      final lista = await todos();
      expect(lista.length, 1);
      expect(lista.first.id, 'manter');

      // As notas do aluno removido também somem (ON DELETE CASCADE).
      final notasOrfas = await service.db.query(
        'notas',
        where: 'aluno_id = ?',
        whereArgs: ['apagar'],
      );
      expect(notasOrfas, isEmpty);
    });

    test('dados persistem em uma nova instância do repositório', () async {
      await repo.cadastrar(_aluno(nome: 'Persistente'));

      // novo repositório sobre o mesmo serviço/banco, como ao reabrir o app
      final repo2 = AlunoRepository(service);
      final lista = (await repo2.buscarTodos() as Success<List<Aluno>>).value;
      expect(lista.length, 1);
      expect(lista.first.nome, 'Persistente');
    });
  });
}
