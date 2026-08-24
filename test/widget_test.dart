import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:piramid_game/app.dart';
import 'package:piramid_game/data/services/database_service.dart';
import 'package:piramid_game/di/service_locator.dart';

import 'helpers/db_util.dart';

void main() {
  setUp(() async {
    habilitarSqfliteFfi();
    await setupServiceLocator(dbPath: inMemoryDatabasePath);
  });

  tearDown(() async {
    await serviceLocator<DatabaseService>().close();
  });

  testWidgets('App sobe na Splash e navega para a Home vazia', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const PiramidGameApp());
    await tester.pump(); // primeiro frame: Splash

    expect(find.text('Pirâmide da Popularidade'), findsOneWidget);
    expect(find.text('IFPR – Campus Paranaguá'), findsOneWidget);

    await tester.pump(const Duration(seconds: 3));
    await tester.pumpAndSettle();

    expect(find.text('Nenhum aluno cadastrado'), findsOneWidget);
    expect(find.text('Novo Aluno'), findsOneWidget);
  });
}
