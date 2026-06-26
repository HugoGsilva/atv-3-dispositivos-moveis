// =============================================================================
// 🗺️ APP - MaterialApp + GoRouter (Configuração Central do App)
// =============================================================================
//
// 🎓 EXPLICAÇÃO PARA APRESENTAÇÃO:
// ---------------------------------
// Este arquivo é o "coração" visual do app. Ele configura:
//
// 1. MaterialApp.router → O widget raiz que envolve todo o app
//    - Define o tema (claro/escuro)
//    - Integra o sistema de rotas (go_router)
//
// 2. GoRouter → Define TODAS as rotas (caminhos) do app
//    Cada rota mapeia um URL para uma tela:
//    - '/' → SplashPage
//    - '/home' → HomePage
//    - '/cadastro' → CadastroPage
//    - '/aluno/:id' → DetalheAlunoPage (com parâmetro dinâmico)
//    - '/ranking' → RankingPage
//    - '/sobre' → SobreAppPage
//
// O go_router é como o GPS do app:
//    context.go('/home')  → navega SUBSTITUINDO a tela atual
//    context.push('/cadastro') → navega EMPILHANDO (pode voltar)
//    context.pop() → volta para a tela anterior
// =============================================================================

import 'package:flutter/material.dart';
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

/// Configuração das rotas do aplicativo.
///
/// Cada GoRoute mapeia um caminho (path) para um widget (tela).
final GoRouter _router = GoRouter(
  // Rota inicial (primeira tela que aparece)
  initialLocation: '/',

  routes: [
    // Splash Screen
    GoRoute(
      path: '/',
      builder: (context, state) => const SplashPage(),
    ),

    // Tela Principal (lista de alunos)
    GoRoute(
      path: '/home',
      builder: (context, state) => const HomePage(),
    ),

    // Cadastro de novo aluno OU edição de aluno existente
    // O 'extra' permite passar objetos complexos entre rotas
    GoRoute(
      path: '/cadastro',
      builder: (context, state) {
        // Se recebemos um Aluno via extra, é modo edição
        final alunoParaEditar = state.extra as Aluno?;
        return CadastroPage(alunoParaEditar: alunoParaEditar);
      },
    ),

    // Detalhe de um aluno específico
    // ':id' é um parâmetro dinâmico (ex: /aluno/abc-123)
    GoRoute(
      path: '/aluno/:id',
      builder: (context, state) {
        final id = state.pathParameters['id']!;
        return DetalheAlunoPage(alunoId: id);
      },
    ),

    // Ranking de popularidade
    GoRoute(
      path: '/ranking',
      builder: (context, state) => const RankingPage(),
    ),

    // Sobre o App
    GoRoute(
      path: '/sobre',
      builder: (context, state) => const SobreAppPage(),
    ),
  ],
);

/// Widget raiz do aplicativo.
///
/// Usa Watch() para observar o signal de tema e alternar
/// automaticamente entre tema claro e escuro.
class PiramidGameApp extends StatelessWidget {
  const PiramidGameApp({super.key});

  @override
  Widget build(BuildContext context) {
    final temaViewModel = serviceLocator<TemaViewModel>();

    // Watch observa o signal isDarkMode
    // Quando ele muda, o MaterialApp inteiro se reconstrói com o novo tema
    return Watch((context) {
      return MaterialApp.router(
        title: 'PiramidGame IFPR-Pguá',
        debugShowCheckedModeBanner: false,

        // Seleciona o tema baseado no signal
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: temaViewModel.isDarkMode.value
            ? ThemeMode.dark
            : ThemeMode.light,

        // Integra o go_router
        routerConfig: _router,
      );
    });
  }
}
