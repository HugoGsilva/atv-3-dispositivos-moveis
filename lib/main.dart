// =============================================================================
// 🚀 MAIN - Ponto de Entrada do Aplicativo
// =============================================================================
//
// 🎓 EXPLICAÇÃO PARA APRESENTAÇÃO:
// ---------------------------------
// O main.dart é o PONTO DE ENTRADA do app — o primeiro código que roda.
//
// main() é a função que o Flutter executa ao iniciar.
//
// Aqui fazemos 3 coisas na ordem:
//   1. WidgetsFlutterBinding.ensureInitialized()
//      → Garante que o Flutter está pronto para uso (necessário antes
//        de usar plugins como SharedPreferences)
//
//   2. setupServiceLocator()
//      → Inicializa todas as dependências (Service, Repository, Use Cases,
//        Facades, ViewModels). Sem isso, nenhuma tela funciona.
//
//   3. runApp(PiramidGameApp())
//      → Inicia o app com o widget raiz (MaterialApp + GoRouter)
//
// A palavra-chave "async" permite usar "await" — esperar que operações
// assíncronas terminem antes de continuar.
// =============================================================================

import 'package:flutter/material.dart';
import 'di/service_locator.dart';
import 'app.dart';

void main() async {
  // 1. Garante que o framework Flutter está inicializado
  //    Necessário porque vamos usar SharedPreferences antes do runApp
  WidgetsFlutterBinding.ensureInitialized();

  // 2. Inicializa todas as dependências do app
  //    Service → Repository → Use Cases → Facades → ViewModels
  await setupServiceLocator();

  // 3. Inicia o aplicativo
  runApp(const PiramidGameApp());
}
