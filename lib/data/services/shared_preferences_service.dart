// =============================================================================
// 🔧 SERVICE - SharedPreferences Service (Camada de Dados)
// =============================================================================
//
// 🎓 EXPLICAÇÃO PARA APRESENTAÇÃO:
// ---------------------------------
// O Service é a camada mais BAIXA da arquitetura. Ele fala diretamente
// com o "mundo externo" — neste caso, o SharedPreferences (armazenamento
// local do celular).
//
// Pense no Service como o FUNCIONÁRIO DO ESTOQUE:
//   - Ele sabe onde os produtos estão guardados
//   - Ele sabe como pegar e guardar produtos
//   - Ele NÃO sabe para que servem os produtos (isso é papel de cima)
//
// O Service NÃO conhece a classe Aluno. Ele só sabe lidar com Strings.
// Isso é o princípio "S" do SOLID (Single Responsibility):
//   → Responsabilidade ÚNICA: acessar SharedPreferences.
//
// SharedPreferences funciona como um "mini banco de dados" no celular.
// Ele salva dados no formato chave → valor:
//   chave: "alunos_json"  →  valor: "[{nome: João, ...}, {nome: Ana, ...}]"
//   chave: "tema_escuro"  →  valor: "true"
// =============================================================================

import 'package:shared_preferences/shared_preferences.dart';

/// Serviço responsável pelo acesso direto ao SharedPreferences.
///
/// Esta é a camada mais baixa — lida apenas com Strings e tipos primitivos.
/// Não conhece modelos de domínio como Aluno.
class SharedPreferencesService {
  /// Instância do SharedPreferences (inicializada no setup do app).
  ///
  /// "late" significa que será inicializada depois, mas ANTES de ser usada.
  /// Fazemos isso porque SharedPreferences.getInstance() é assíncrono.
  late final SharedPreferences _prefs;

  /// Inicializa o serviço obtendo a instância do SharedPreferences.
  ///
  /// DEVE ser chamado uma vez no início do app (no main.dart).
  /// É assíncrono porque o SharedPreferences precisa acessar o disco.
  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  // ===========================================================================
  // OPERAÇÕES CRUD (Create, Read, Update, Delete)
  // ===========================================================================

  /// Salva uma String associada a uma chave.
  ///
  /// Exemplo: saveString('alunos_json', '[{"nome":"João",...}]')
  Future<bool> saveString(String key, String value) async {
    return await _prefs.setString(key, value);
  }

  /// Lê uma String a partir de uma chave.
  /// Retorna null se a chave não existir.
  ///
  /// Exemplo: getString('alunos_json') → '[{"nome":"João",...}]' ou null
  String? getString(String key) {
    return _prefs.getString(key);
  }

  /// Salva um bool associado a uma chave.
  ///
  /// Exemplo: saveBool('tema_escuro', true)
  Future<bool> saveBool(String key, bool value) async {
    return await _prefs.setBool(key, value);
  }

  /// Lê um bool a partir de uma chave.
  /// Retorna null se a chave não existir.
  bool? getBool(String key) {
    return _prefs.getBool(key);
  }

  /// Remove um dado a partir de sua chave.
  ///
  /// Exemplo: remove('alunos_json') → apaga todos os alunos salvos
  Future<bool> remove(String key) async {
    return await _prefs.remove(key);
  }
}
