import 'package:flutter_test/flutter_test.dart';
import 'package:piramid_game/core/constants.dart';
import 'package:piramid_game/domain/models/aluno.dart';

void main() {
  group('Aluno', () {
    test('notas default: 15 critérios, todos com nota mínima (1)', () {
      final aluno = Aluno(
        nome: 'Ana',
        curso: 'INFO',
        turmaAno: 2024,
        dataNascimento: DateTime(2005, 1, 1),
      );

      expect(aluno.notas.length, kCriterios.length);
      expect(aluno.notas.length, 15);
      expect(aluno.notas.values.every((n) => n == kNotaMinima), isTrue);
      expect(aluno.nivelLenda, kPontuacaoMinima);
      expect(aluno.nivelLenda, 15);
    });

    test('nivelLenda soma corretamente as notas (máximo = 75)', () {
      final notasMax = {for (final c in kCriterios) c['id']!: kNotaMaxima};
      final aluno = Aluno(
        nome: 'Lenda',
        curso: 'TADS',
        turmaAno: 2026,
        dataNascimento: DateTime(2000, 5, 20),
        notas: notasMax,
      );
      expect(aluno.nivelLenda, kPontuacaoMaxima);
      expect(aluno.nivelLenda, 75);
    });

    test('gera um id (UUID) automaticamente quando não informado', () {
      final a1 = Aluno(
        nome: 'A',
        curso: 'MEC',
        turmaAno: 2010,
        dataNascimento: DateTime(2001, 1, 1),
      );
      final a2 = Aluno(
        nome: 'B',
        curso: 'MEC',
        turmaAno: 2010,
        dataNascimento: DateTime(2001, 1, 1),
      );
      expect(a1.id, isNotEmpty);
      expect(a1.id, isNot(a2.id));
    });

    test('toJson/fromJson preserva todos os dados (round-trip)', () {
      final original = Aluno(
        id: 'fixo-123',
        nome: 'João Pedro',
        curso: 'MEC',
        turmaAno: 2023,
        apelido: 'JP',
        dataNascimento: DateTime(2004, 7, 15),
        notas: {for (final c in kCriterios) c['id']!: 3},
      );

      final json = original.toJson();
      final restaurado = Aluno.fromJson(json);

      expect(restaurado.id, original.id);
      expect(restaurado.nome, original.nome);
      expect(restaurado.curso, original.curso);
      expect(restaurado.turmaAno, original.turmaAno);
      expect(restaurado.apelido, original.apelido);
      expect(restaurado.dataNascimento, original.dataNascimento);
      expect(restaurado.notas, original.notas);
      expect(restaurado.nivelLenda, original.nivelLenda);
    });

    test('copyWith mantém o id e altera só os campos informados', () {
      final original = Aluno(
        id: 'mesmo-id',
        nome: 'Maria',
        curso: 'MAMB',
        turmaAno: 2025,
        dataNascimento: DateTime(2003, 3, 3),
      );

      final alterado = original.copyWith(nome: 'Maria Eduarda', curso: 'PROD');

      expect(alterado.id, 'mesmo-id');
      expect(alterado.nome, 'Maria Eduarda');
      expect(alterado.curso, 'PROD');
      expect(alterado.turmaAno, original.turmaAno);
      expect(alterado.dataNascimento, original.dataNascimento);
      // copyWith não muta o original
      expect(original.nome, 'Maria');
      expect(original.curso, 'MAMB');
    });
  });
}
