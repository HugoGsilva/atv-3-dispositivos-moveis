import 'package:signals_flutter/signals_flutter.dart';
import '../../data/services/shared_preferences_service.dart';
import '../../core/constants.dart';

/// ViewModel responsável pelo controle do tema claro/escuro.
class TemaViewModel {
  final SharedPreferencesService _service;

  /// Indica se o tema escuro está ativo.
  final isDarkMode = signal<bool>(false);

  TemaViewModel(this._service);

  /// Carrega a preferência de tema salva no dispositivo.
  void carregarTema() {
    final salvo = _service.getBool(kChaveTemaEscuro);
    if (salvo != null) {
      isDarkMode.value = salvo;
    }
  }

  /// Alterna entre tema claro e escuro, persistindo a escolha.
  Future<void> alternarTema() async {
    isDarkMode.value = !isDarkMode.value;
    await _service.saveBool(kChaveTemaEscuro, isDarkMode.value);
  }
}
