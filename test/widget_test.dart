// =============================================================================
// 🧪 TESTE DE WIDGET - Smoke test do app completo
// =============================================================================
//
// Boota o app de verdade (Service Locator + SharedPreferences mock) e verifica:
//   - A Splash aparece no primeiro frame
//   - Após o tempo de splash, navega para a Home (estado vazio, sem alunos)
//
// É um teste de integração leve: garante que a árvore de dependências
// (service -> repository -> use cases -> facade -> viewmodels -> UI) sobe sem
// erros e que a navegação inicial (go_router) funciona.
// =============================================================================

import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:piramid_game/app.dart';
import 'package:piramid_game/di/service_locator.dart';

void main() {
  setUp(() async {
    // Armazenamento limpo + todas as dependências registradas
    SharedPreferences.setMockInitialValues({});
    await setupServiceLocator();
  });

  testWidgets('App sobe na Splash e navega para a Home vazia',
      (WidgetTester tester) async {
    await tester.pumpWidget(const PiramidGameApp());
    await tester.pump(); // primeiro frame: Splash

    // Splash exibe o nome do app e a referência ao IFPR
    expect(find.text('PiramidGame'), findsOneWidget);
    expect(find.text('IFPR – Campus Paranaguá'), findsOneWidget);

    // Avança o tempo do splash (3s) para disparar a navegação para /home
    await tester.pump(const Duration(seconds: 3));
    await tester.pumpAndSettle();

    // Home vazia: mensagem de "nenhum aluno" e botão de novo aluno
    expect(find.text('Nenhum aluno cadastrado'), findsOneWidget);
    expect(find.text('Novo Aluno'), findsOneWidget);
  });
}
