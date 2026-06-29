// Teste end-to-end de fluxo: sobe o app real e dirige a UI pelas telas,
// passando por todas as camadas (UI → ViewModel → Facade → Use Case →
// Repository → Service com SharedPreferences mock).

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:piramid_game/app.dart';
import 'package:piramid_game/di/service_locator.dart';

void main() {
  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await setupServiceLocator();
  });

  Future<void> bootAteHome(WidgetTester tester) async {
    await tester.pumpWidget(const PiramidGameApp());
    await tester.pump(); // primeiro frame: Splash
    await tester.pump(const Duration(seconds: 3)); // tempo do splash
    await tester.pumpAndSettle(); // navega para a Home
  }

  // O botão de salvar fica no fim de um ListView (construído sob demanda),
  // então é preciso rolar até ele antes de tocar.
  Future<void> tocarEmSalvar(WidgetTester tester) async {
    final botao = find.text('Cadastrar aluno');
    await tester.scrollUntilVisible(
      botao,
      300,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pumpAndSettle();
    await tester.tap(botao);
    await tester.pumpAndSettle();
  }

  testWidgets('E2E: cadastra um aluno, vê na lista e no ranking, e remove', (
    tester,
  ) async {
    await bootAteHome(tester);
    expect(find.text('Nenhum aluno cadastrado'), findsOneWidget);

    // Abre o formulário de cadastro
    await tester.tap(find.text('Novo Aluno'));
    await tester.pumpAndSettle();

    // Preenche o nome (1º TextFormField da tela)
    await tester.enterText(find.byType(TextFormField).at(0), 'Ana Clara');
    await tester.pump();

    await tocarEmSalvar(tester);

    // Voltou para a Home e o aluno aparece na lista
    expect(find.text('Nenhum aluno cadastrado'), findsNothing);
    expect(find.text('Ana Clara'), findsWidgets);

    // Abre o Ranking pelo ícone na AppBar e confere que o aluno está lá
    await tester.tap(find.byIcon(Icons.leaderboard_rounded));
    await tester.pumpAndSettle();
    expect(find.text('Ana Clara'), findsWidgets);

    // Volta para a Home (botão de voltar da AppBar)
    await tester.tap(find.byType(BackButton));
    await tester.pumpAndSettle();

    // Remove pelo botão de lixeira do card e confirma no diálogo
    await tester.tap(find.byIcon(Icons.delete_outline_rounded).first);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Remover'));
    await tester.pumpAndSettle();

    // Lista voltou a ficar vazia
    expect(find.text('Nenhum aluno cadastrado'), findsOneWidget);
  });

  testWidgets('E2E: a validação bloqueia um nome inválido ("123")', (
    tester,
  ) async {
    await bootAteHome(tester);

    await tester.tap(find.text('Novo Aluno'));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextFormField).at(0), '123');
    await tester.pumpAndSettle();

    // Com autovalidateMode, o erro aparece já ao digitar.
    expect(find.text('O nome deve conter letras'), findsOneWidget);

    // Tenta salvar: continua na tela de cadastro (não salvou). O título da
    // AppBar da tela de cadastro é "Novo Aluno"; a Home não é exibida.
    await tocarEmSalvar(tester);
    expect(find.text('Novo Aluno'), findsOneWidget);
    expect(find.text('Nenhum aluno cadastrado'), findsNothing);
  });
}
