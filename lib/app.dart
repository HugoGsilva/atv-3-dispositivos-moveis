import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:go_router/go_router.dart';
import 'package:signals_flutter/signals_flutter.dart';
import 'di/service_locator.dart';
import 'domain/models/aluno.dart';
import 'presentation/theme/app_theme.dart';
import 'presentation/viewmodels/tema_viewmodel.dart';
import 'presentation/pages/splash_page.dart';
import 'presentation/pages/home_page.dart';
import 'presentation/pages/cadastro_page.dart';
import 'presentation/pages/detalhe_aluno_page.dart';
import 'presentation/pages/ranking_page.dart';
import 'presentation/pages/sobre_app_page.dart';

final GoRouter _router = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(path: '/', builder: (context, state) => const SplashPage()),
    GoRoute(path: '/home', builder: (context, state) => const HomePage()),
    GoRoute(
      path: '/cadastro',
      builder: (context, state) {
        final alunoParaEditar = state.extra as Aluno?;
        return CadastroPage(alunoParaEditar: alunoParaEditar);
      },
    ),
    GoRoute(
      path: '/aluno/:id',
      builder: (context, state) {
        final id = state.pathParameters['id']!;
        return DetalheAlunoPage(alunoId: id);
      },
    ),
    GoRoute(path: '/ranking', builder: (context, state) => const RankingPage()),
    GoRoute(path: '/sobre', builder: (context, state) => const SobreAppPage()),
  ],
);

class PiramidGameApp extends StatelessWidget {
  const PiramidGameApp({super.key});

  @override
  Widget build(BuildContext context) {
    final temaViewModel = serviceLocator<TemaViewModel>();

    return Watch((context) {
      return MaterialApp.router(
        title: 'Pódio da Turma — IFPR-Pguá',
        debugShowCheckedModeBanner: false,

        // Localização pt-BR (calendário, tooltips e textos padrão do Material).
        locale: const Locale('pt', 'BR'),
        supportedLocales: const [Locale('pt', 'BR')],
        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],

        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: temaViewModel.isDarkMode.value
            ? ThemeMode.dark
            : ThemeMode.light,
        routerConfig: _router,
      );
    });
  }
}
