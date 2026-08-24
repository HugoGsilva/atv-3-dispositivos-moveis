import 'package:sqflite_common_ffi/sqflite_common_ffi.dart';
import 'package:piramid_game/data/services/database_service.dart';

/// Habilita o sqflite via FFI (necessário para rodar SQLite fora de um
/// dispositivo, no ambiente de testes do Dart VM).
void habilitarSqfliteFfi() {
  sqfliteFfiInit();
  databaseFactory = databaseFactoryFfi;
}

/// Cria um [DatabaseService] apontando para um banco em memória, isolado a
/// cada teste. Também configura o factory FFI.
Future<DatabaseService> criarDatabaseServiceEmMemoria() async {
  habilitarSqfliteFfi();
  final service = DatabaseService();
  await service.init(path: inMemoryDatabasePath);
  return service;
}
