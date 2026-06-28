import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:piramid_game/core/constants.dart';
import 'package:piramid_game/core/result.dart';
import 'package:piramid_game/data/repositories/aluno_repository.dart';
import 'package:piramid_game/data/services/shared_preferences_service.dart';
import 'package:piramid_game/domain/models/aluno.dart';
import 'package:piramid_game/domain/use_cases/aluno_use_cases.dart';

Aluno _alunoComTotal({required String nome, required int notaEmCadaCriterio}) {
  return Aluno(
    nome: nome,
    curso: 'INFO',
    turmaAno: 2024,
    dataNascimento: DateTime(2005, 1, 1),
    notas: {for (final c in kCriterios) c['id']!: notaEmCadaCriterio},
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

  group('CadastrarAlunoUseCase', () {
    test('rejeita nome vazio com Failure e NÃO persiste', () async {
      final useCase = CadastrarAlunoUseCase(repo);
      final r = await useCase(
        _alunoComTotal(nome: '   ', notaEmCadaCriterio: 1),
      );

      expect(r, isA<Failure>());
      expect((r as Failure).message, contains('nome'));
      expect((repo.buscarTodos() as Success<List<Aluno>>).value, isEmpty);
    });

    test('cadastra quando o nome é válido', () async {
      final useCase = CadastrarAlunoUseCase(repo);
      final r = await useCase(
        _alunoComTotal(nome: 'Válido', notaEmCadaCriterio: 2),
      );

      expect(r, isA<Success>());
      expect((repo.buscarTodos() as Success<List<Aluno>>).value.length, 1);
    });
  });

  group('AlterarAlunoUseCase', () {
    test('rejeita nome vazio com Failure', () async {
      final useCase = AlterarAlunoUseCase(repo);
      final r = await useCase(_alunoComTotal(nome: '', notaEmCadaCriterio: 1));
      expect(r, isA<Failure>());
    });
  });

  group('RemoverAlunoUseCase', () {
    test('rejeita id vazio com Failure', () async {
      final useCase = RemoverAlunoUseCase(repo);
      final r = await useCase('');
      expect(r, isA<Failure>());
    });
  });

  group('CalcularRankingUseCase', () {
    test('ordena do MAIOR para o MENOR Nível Lenda', () async {
      await repo.cadastrar(
        _alunoComTotal(nome: 'Baixo', notaEmCadaCriterio: 1),
      );
      await repo.cadastrar(_alunoComTotal(nome: 'Alto', notaEmCadaCriterio: 5));
      await repo.cadastrar(
        _alunoComTotal(nome: 'Medio', notaEmCadaCriterio: 3),
      );

      final useCase = CalcularRankingUseCase(repo);
      final ranking = (useCase() as Success<List<Aluno>>).value;

      expect(ranking.map((a) => a.nome), ['Alto', 'Medio', 'Baixo']);
      expect(ranking.first.nivelLenda, 75);
      expect(ranking.last.nivelLenda, 15);
    });

    test('ranking vazio quando não há alunos', () {
      final useCase = CalcularRankingUseCase(repo);
      final ranking = (useCase() as Success<List<Aluno>>).value;
      expect(ranking, isEmpty);
    });
  });
}
