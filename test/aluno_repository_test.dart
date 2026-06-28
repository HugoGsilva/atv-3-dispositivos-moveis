import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:piramid_game/core/result.dart';
import 'package:piramid_game/data/repositories/aluno_repository.dart';
import 'package:piramid_game/data/services/shared_preferences_service.dart';
import 'package:piramid_game/domain/models/aluno.dart';

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
  late SharedPreferencesService service;
  late AlunoRepository repo;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    service = SharedPreferencesService();
    await service.init();
    repo = AlunoRepository(service);
  });

  group('AlunoRepository', () {
    test('buscarTodos retorna lista vazia quando não há dados', () {
      final r = repo.buscarTodos();
      expect(r, isA<Success<List<Aluno>>>());
      expect((r as Success<List<Aluno>>).value, isEmpty);
    });

    test('cadastrar persiste o aluno e buscarTodos o retorna', () async {
      final r = await repo.cadastrar(_aluno(nome: 'Ana'));
      expect(r, isA<Success>());

      final lista = (repo.buscarTodos() as Success<List<Aluno>>).value;
      expect(lista.length, 1);
      expect(lista.first.nome, 'Ana');
    });

    test('cadastrar vários acumula (não sobrescreve)', () async {
      await repo.cadastrar(_aluno(nome: 'A'));
      await repo.cadastrar(_aluno(nome: 'B'));
      await repo.cadastrar(_aluno(nome: 'C'));

      final lista = (repo.buscarTodos() as Success<List<Aluno>>).value;
      expect(lista.map((a) => a.nome), containsAll(['A', 'B', 'C']));
      expect(lista.length, 3);
    });

    test('buscarPorId encontra o aluno certo', () async {
      await repo.cadastrar(_aluno(id: 'id-1', nome: 'Um'));
      await repo.cadastrar(_aluno(id: 'id-2', nome: 'Dois'));

      final r = repo.buscarPorId('id-2');
      expect(r, isA<Success<Aluno>>());
      expect((r as Success<Aluno>).value.nome, 'Dois');
    });

    test('buscarPorId retorna Failure quando o id não existe', () {
      final r = repo.buscarPorId('inexistente');
      expect(r, isA<Failure>());
      expect((r as Failure).message, contains('não encontrado'));
    });

    test('alterar substitui os dados do aluno pelo id', () async {
      await repo.cadastrar(_aluno(id: 'id-x', nome: 'Antigo'));

      final atualizado = _aluno(id: 'id-x', nome: 'Novo', curso: 'TADS');
      final r = await repo.alterar(atualizado);
      expect(r, isA<Success>());

      final encontrado = (repo.buscarPorId('id-x') as Success<Aluno>).value;
      expect(encontrado.nome, 'Novo');
      expect(encontrado.curso, 'TADS');
    });

    test('alterar retorna Failure quando o id não existe', () async {
      final r = await repo.alterar(_aluno(id: 'nao-existe'));
      expect(r, isA<Failure>());
    });

    test('remover exclui o aluno pelo id', () async {
      await repo.cadastrar(_aluno(id: 'manter', nome: 'Fica'));
      await repo.cadastrar(_aluno(id: 'apagar', nome: 'Sai'));

      final r = await repo.remover('apagar');
      expect(r, isA<Success>());

      final lista = (repo.buscarTodos() as Success<List<Aluno>>).value;
      expect(lista.length, 1);
      expect(lista.first.id, 'manter');
    });

    test('dados persistem em uma nova instância do repositório', () async {
      await repo.cadastrar(_aluno(nome: 'Persistente'));

      // novo repositório sobre o mesmo serviço, como ao reabrir o app
      final repo2 = AlunoRepository(service);
      final lista = (repo2.buscarTodos() as Success<List<Aluno>>).value;
      expect(lista.length, 1);
      expect(lista.first.nome, 'Persistente');
    });
  });
}
