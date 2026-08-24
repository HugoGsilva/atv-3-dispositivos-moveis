// Testes end-to-end: sobem o app real e dirigem a UI pelas telas, passando por
// todas as camadas (UI → ViewModel → Facade → Use Case → Repository → Service
// com SQLite em memória via sqflite_common_ffi).
//
// O fluxo principal roda numa ÚNICA sessão do app (um pumpWidget só), exercitando
// todas as funcionalidades em sequência. Isso evita contaminação entre testes
// causada por singletons globais do app (GoRouter, Service Locator).

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:piramid_game/app.dart';
import 'package:piramid_game/data/services/database_service.dart';
import 'package:piramid_game/di/service_locator.dart';
import 'package:piramid_game/presentation/widgets/aluno_card.dart';

import 'helpers/db_util.dart';

void main() {
  setUp(() async {
    habilitarSqfliteFfi();
    await setupServiceLocator(dbPath: inMemoryDatabasePath);
  });

  tearDown(() async {
    await serviceLocator<DatabaseService>().close();
  });

  Future<void> bootAteHome(WidgetTester tester) async {
    await tester.pumpWidget(const PiramidGameApp());
    await tester.pump(); // primeiro frame: Splash
    await tester.pump(const Duration(seconds: 3)); // tempo do splash
    await tester.pumpAndSettle(); // navega para a Home
  }

  // O botão de salvar fica no fim de um ListView (construído sob demanda),
  // então é preciso rolar até ele antes de tocar.
  Future<void> tocarEmBotao(WidgetTester tester, String texto) async {
    final botao = find.text(texto);
    await tester.scrollUntilVisible(
      botao,
      300,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pumpAndSettle();
    await tester.tap(botao);
    await tester.pumpAndSettle();
  }

  // Deixa o SnackBar (timer de ~4s) expirar.
  Future<void> limparSnackBars(WidgetTester tester) async {
    await tester.pump(const Duration(seconds: 4));
    await tester.pumpAndSettle();
  }

  testWidgets(
    'E2E completo: tema, sobre, cadastro, detalhe, edição, ranking e remoção',
    (tester) async {
      await bootAteHome(tester);
      expect(find.text('Nenhum aluno cadastrado'), findsOneWidget);

      // ---- Alternar tema (claro ↔ escuro) -------------------------------
      expect(find.byIcon(Icons.dark_mode_rounded), findsOneWidget);
      await tester.tap(find.byIcon(Icons.dark_mode_rounded));
      await tester.pumpAndSettle();
      expect(find.byIcon(Icons.light_mode_rounded), findsOneWidget);
      await tester.tap(find.byIcon(Icons.light_mode_rounded)); // volta ao claro
      await tester.pumpAndSettle();

      // ---- Tela "Sobre o App" -------------------------------------------
      await tester.tap(find.byIcon(Icons.info_outline_rounded));
      await tester.pumpAndSettle();
      expect(find.text('Sobre o App'), findsOneWidget);
      expect(find.text('Objetivo'), findsOneWidget);
      await tester.tap(find.byType(BackButton));
      await tester.pumpAndSettle();

      // ---- Cadastrar um aluno -------------------------------------------
      await tester.tap(find.text('Novo Aluno'));
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextFormField).at(0), 'Ana Clara');
      await tester.pump();
      await tocarEmBotao(tester, 'Cadastrar aluno');
      await limparSnackBars(tester);

      expect(find.text('Nenhum aluno cadastrado'), findsNothing);
      expect(find.text('Ana Clara'), findsWidgets);

      // ---- Abrir o detalhe (Nível Lenda + notas) ------------------------
      await tester.tap(find.byType(AlunoCard));
      await tester.pumpAndSettle();
      expect(find.text('NÍVEL LENDA'), findsOneWidget);
      expect(find.text('Notas por critério'), findsOneWidget);

      // ---- Editar o aluno -----------------------------------------------
      await tester.tap(find.byIcon(Icons.edit_rounded));
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextFormField).at(0), 'Ana Editada');
      await tester.pump();
      await tocarEmBotao(tester, 'Salvar alterações');
      await limparSnackBars(tester);
      expect(find.text('Ana Editada'), findsWidgets);

      // Volta do detalhe para a Home
      await tester.tap(find.byType(BackButton));
      await tester.pumpAndSettle();

      // ---- Ranking ------------------------------------------------------
      await tester.tap(find.byIcon(Icons.leaderboard_rounded));
      await tester.pumpAndSettle();
      expect(find.text('Ana Editada'), findsWidgets);
      await tester.tap(find.byType(BackButton));
      await tester.pumpAndSettle();

      // ---- Remover (botão de lixeira do card + confirmação) -------------
      await tester.tap(find.byIcon(Icons.delete_outline_rounded).first);
      await tester.pumpAndSettle();
      await tester.tap(find.text('Remover'));
      await tester.pumpAndSettle();
      expect(find.text('Nenhum aluno cadastrado'), findsOneWidget);
      await limparSnackBars(tester);
    },
  );

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

    // Tenta salvar: continua na tela de cadastro (não salvou).
    await tocarEmBotao(tester, 'Cadastrar aluno');
    expect(find.text('Novo Aluno'), findsOneWidget);
    expect(find.text('Nenhum aluno cadastrado'), findsNothing);
  });
}
