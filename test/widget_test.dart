import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:piramid_game/app.dart';
import 'package:piramid_game/di/service_locator.dart';

void main() {
  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await setupServiceLocator();
  });

  testWidgets('App sobe na Splash e navega para a Home vazia', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const PiramidGameApp());
    await tester.pump(); // primeiro frame: Splash

    expect(find.text('Pódio da Turma'), findsOneWidget);
    expect(find.text('IFPR – Campus Paranaguá'), findsOneWidget);

    await tester.pump(const Duration(seconds: 3));
    await tester.pumpAndSettle();

    expect(find.text('Nenhum aluno cadastrado'), findsOneWidget);
    expect(find.text('Novo Aluno'), findsOneWidget);
  });
}
