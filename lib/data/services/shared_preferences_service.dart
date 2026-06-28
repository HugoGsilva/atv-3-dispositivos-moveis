import 'package:shared_preferences/shared_preferences.dart';

/// Acesso direto ao SharedPreferences. Lida apenas com tipos primitivos,
/// sem conhecer modelos de domínio como Aluno.
class SharedPreferencesService {
  late final SharedPreferences _prefs;

  /// Deve ser chamado uma vez no início do app (no main.dart).
  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  Future<bool> saveString(String key, String value) async {
    return await _prefs.setString(key, value);
  }

  String? getString(String key) {
    return _prefs.getString(key);
  }

  Future<bool> saveBool(String key, bool value) async {
    return await _prefs.setBool(key, value);
  }

  bool? getBool(String key) {
    return _prefs.getBool(key);
  }

  Future<bool> remove(String key) async {
    return await _prefs.remove(key);
  }
}
