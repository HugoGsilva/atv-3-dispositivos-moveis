// =============================================================================
// 🧪 TESTES - Padrão Command
// =============================================================================
//
// O Command encapsula uma ação e expõe estado reativo (running/result/error).
// Cobre:
//   - Command0: sucesso atualiza result, zera error e desliga running
//   - Command0: Failure preenche error
//   - Command0: exceção inesperada vira Failure
//   - proteção contra duplo clique (não executa de novo enquanto running)
//   - Command1: passa o argumento para a ação
// =============================================================================

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

    test('proteção contra duplo clique: ignora a 2ª chamada enquanto roda',
        () async {
      var execucoes = 0;
      final completer = Completer<Result<int>>();
      final cmd = Command0<int>(() async {
        execucoes++;
        return completer.future; // mantém o command "running"
      });

      final primeira = cmd.execute(); // dispara e fica pendente
      expect(cmd.running.value, isTrue);

      await cmd.execute(); // deve ser ignorada (já está running)
      expect(execucoes, 1);

      completer.complete(const Success(1)); // libera a primeira
      await primeira;
      expect(cmd.running.value, isFalse);
    });
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
