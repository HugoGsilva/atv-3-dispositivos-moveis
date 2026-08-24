import 'package:signals_flutter/signals_flutter.dart';
import '../../data/services/database_service.dart';
import '../../core/constants.dart';

/// ViewModel responsável pelo controle do tema claro/escuro.
class TemaViewModel {
  final DatabaseService _service;

  /// Indica se o tema escuro está ativo.
  final isDarkMode = signal<bool>(false);

  TemaViewModel(this._service);

  /// Carrega a preferência de tema salva no banco (tabela `config`).
  Future<void> carregarTema() async {
    final salvo = await _service.getConfig(kChaveTemaEscuro);
    if (salvo != null) {
      isDarkMode.value = salvo == 'true';
    }
  }

  /// Alterna entre tema claro e escuro, persistindo a escolha.
  Future<void> alternarTema() async {
    isDarkMode.value = !isDarkMode.value;
    await _service.setConfig(kChaveTemaEscuro, isDarkMode.value.toString());
  }
}
