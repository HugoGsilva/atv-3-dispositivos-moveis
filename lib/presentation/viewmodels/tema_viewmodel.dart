// =============================================================================
// 🌓 TEMA VIEWMODEL - Controle de Tema Claro/Escuro
// =============================================================================
//
// 🎓 EXPLICAÇÃO PARA APRESENTAÇÃO:
// ---------------------------------
// Este ViewModel controla o tema do app (claro ↔ escuro).
// Usa Flutter Signals para que a troca seja REATIVA:
//   - Quando isDarkMode muda, toda a UI se atualiza automaticamente
//   - A preferência é salva no SharedPreferences para persistir
//
// O tema é um "estado global" — afeta o app INTEIRO.
// =============================================================================

import 'package:signals_flutter/signals_flutter.dart';
import '../../data/services/shared_preferences_service.dart';
import '../../core/constants.dart';

/// ViewModel responsável pelo controle do tema claro/escuro.
class TemaViewModel {
  final SharedPreferencesService _service;

  /// Signal reativo: indica se o tema escuro está ativo.
  /// Toda a UI que observar este signal se reconstrói quando ele muda.
  final isDarkMode = signal<bool>(false);

  TemaViewModel(this._service);

  /// Carrega a preferência de tema salva no dispositivo.
  /// Chamado uma vez no início do app.
  void carregarTema() {
    final salvo = _service.getBool(kChaveTemaEscuro);
    if (salvo != null) {
      isDarkMode.value = salvo;
    }
  }

  /// Alterna entre tema claro e escuro.
  /// Salva a escolha no SharedPreferences para persistir.
  Future<void> alternarTema() async {
    isDarkMode.value = !isDarkMode.value;
    await _service.saveBool(kChaveTemaEscuro, isDarkMode.value);
  }
}
