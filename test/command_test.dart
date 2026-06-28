import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:piramid_game/core/command.dart';
import 'package:piramid_game/core/result.dart';

void main() {
  group('Command0', () {
    test('sucesso: result = Success, error = null, running = false', () async {
      final cmd = Command0<int>(() async => const Success(10));
      await cmd.execute();

      expect(cmd.result.value, isA<Success<int>>());
      expect((cmd.result.value as Success<int>).value, 10);
      expect(cmd.error.value, isNull);
      expect(cmd.running.value, isFalse);
    });

    test('Failure: error recebe a mensagem', () async {
      final cmd = Command0<int>(() async => const Failure('falhou'));
      await cmd.execute();

      expect(cmd.result.value, isA<Failure<int>>());
      expect(cmd.error.value, 'falhou');
      expect(cmd.running.value, isFalse);
    });

    test('exceção inesperada é convertida em Failure', () async {
      final cmd = Command0<int>(() async => throw Exception('boom'));
      await cmd.execute();

      expect(cmd.result.value, isA<Failure<int>>());
      expect(cmd.error.value, contains('boom'));
      expect(cmd.running.value, isFalse);
    });

    test(
      'proteção contra duplo clique: ignora a 2ª chamada enquanto roda',
      () async {
        var execucoes = 0;
        final completer = Completer<Result<int>>();
        final cmd = Command0<int>(() async {
          execucoes++;
          return completer.future; // mantém o command running
        });

        final primeira = cmd.execute();
        expect(cmd.running.value, isTrue);

        await cmd.execute(); // ignorada porque já está running
        expect(execucoes, 1);

        completer.complete(const Success(1));
        await primeira;
        expect(cmd.running.value, isFalse);
      },
    );
  });

  group('Command1', () {
    test('passa o argumento para a ação', () async {
      String? recebido;
      final cmd = Command1<void, String>((arg) async {
        recebido = arg;
        return const Success(null);
      });

      await cmd.execute('abc-123');

      expect(recebido, 'abc-123');
      expect(cmd.result.value, isA<Success<void>>());
    });
  });
}
