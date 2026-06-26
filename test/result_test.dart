// =============================================================================
// 🧪 TESTES - Padrão Result
// =============================================================================
//
// Valida o "envelope" de retorno entre as camadas: Success carrega um valor,
// Failure carrega uma mensagem. O switch/pattern-matching deve distinguir os
// dois casos (base de TODA a comunicação entre camadas do app).
// =============================================================================

import 'package:flutter_test/flutter_test.dart';
import 'package:piramid_game/core/result.dart';

void main() {
  group('Result', () {
    test('Success carrega o valor e é reconhecido pelo tipo', () {
      const Result<int> r = Success(42);
      expect(r, isA<Success<int>>());
      expect((r as Success<int>).value, 42);
    });

    test('Failure carrega a mensagem e é reconhecido pelo tipo', () {
      const Result<int> r = Failure('deu ruim');
      expect(r, isA<Failure<int>>());
      expect((r as Failure<int>).message, 'deu ruim');
    });

    test('pattern matching separa Success de Failure', () {
      String descrever(Result<String> r) => switch (r) {
            Success(value: final v) => 'ok:$v',
            Failure(message: final m) => 'erro:$m',
          };

      expect(descrever(const Success('x')), 'ok:x');
      expect(descrever(const Failure('y')), 'erro:y');
    });
  });
}
