import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart';

/// Acesso ao banco SQLite local (sqflite). Abre/cria o banco, define o schema
/// e expõe a instância [Database]. Não conhece modelos de domínio como Aluno —
/// isso é responsabilidade do repositório.
class DatabaseService {
  static const String _nomeBanco = 'piramid_game.db';
  static const int _versao = 1;

  late final Database _db;

  /// Instância do banco já aberto. Use apenas após [init].
  Database get db => _db;

  /// Deve ser chamado uma vez no início do app (no main.dart).
  ///
  /// [path] permite injetar um caminho customizado (ex.: `inMemoryDatabasePath`
  /// nos testes); em produção fica nulo e usa o diretório padrão do dispositivo.
  Future<void> init({String? path}) async {
    final caminho = path ?? p.join(await getDatabasesPath(), _nomeBanco);
    _db = await openDatabase(
      caminho,
      version: _versao,
      onConfigure: _onConfigure,
      onCreate: _onCreate,
    );
  }

  /// Liga a checagem de chaves estrangeiras (desligada por padrão no sqflite),
  /// necessária para o ON DELETE CASCADE das notas.
  Future<void> _onConfigure(Database db) async {
    await db.execute('PRAGMA foreign_keys = ON');
  }

  /// Cria o schema na primeira execução: alunos + notas (normalizado) + config.
  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE alunos (
        id              TEXT PRIMARY KEY,
        nome            TEXT NOT NULL,
        curso           TEXT NOT NULL,
        turma_ano       INTEGER NOT NULL,
        apelido         TEXT NOT NULL DEFAULT '',
        data_nascimento TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE notas (
        aluno_id    TEXT NOT NULL,
        criterio_id TEXT NOT NULL,
        nota        INTEGER NOT NULL,
        PRIMARY KEY (aluno_id, criterio_id),
        FOREIGN KEY (aluno_id) REFERENCES alunos(id) ON DELETE CASCADE
      )
    ''');

    await db.execute('''
      CREATE TABLE config (
        chave TEXT PRIMARY KEY,
        valor TEXT NOT NULL
      )
    ''');
  }

  /// Lê um valor da tabela [config]. Retorna null se a chave não existir.
  Future<String?> getConfig(String chave) async {
    final linhas = await _db.query(
      'config',
      columns: ['valor'],
      where: 'chave = ?',
      whereArgs: [chave],
      limit: 1,
    );
    if (linhas.isEmpty) return null;
    return linhas.first['valor'] as String;
  }

  /// Grava (insere ou substitui) um valor na tabela [config].
  Future<void> setConfig(String chave, String valor) async {
    await _db.insert(
      'config',
      {'chave': chave, 'valor': valor},
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }
}
