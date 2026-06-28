import 'package:uuid/uuid.dart';
import '../../core/constants.dart';

/// Modelo que representa um Aluno cadastrado no sistema.
///
/// Possui dados cadastrais e notas em 15 critérios de popularidade,
/// cuja soma forma o "Nível Lenda" (15 a 75 pontos).
class Aluno {
  /// Identificador único do aluno (UUID v4), gerado no cadastro.
  final String id;

  /// Nome completo do aluno (obrigatório).
  final String nome;

  /// Curso do aluno (INFO, MEC, MAMB, PROD, TADS, TGA).
  final String curso;

  /// Ano/turma do aluno (1998 a 2026).
  final int turmaAno;

  /// Apelido do aluno (opcional, pode ser vazio).
  final String apelido;

  /// Data de nascimento do aluno.
  final DateTime dataNascimento;

  /// Notas dos 15 critérios: chave = ID do critério, valor = nota de 1 a 5.
  final Map<String, int> notas;

  Aluno({
    String? id,
    required this.nome,
    required this.curso,
    required this.turmaAno,
    this.apelido = '',
    required this.dataNascimento,
    Map<String, int>? notas,
  }) : id = id ?? const Uuid().v4(),
       notas = notas ?? {for (final c in kCriterios) c['id']!: kNotaMinima};

  /// Nível Lenda = soma de todas as notas dos 15 critérios (15 a 75).
  int get nivelLenda => notas.values.fold(0, (soma, nota) => soma + nota);

  /// Converte este Aluno para um `Map<String, dynamic>` (formato JSON).
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nome': nome,
      'curso': curso,
      'turmaAno': turmaAno,
      'apelido': apelido,
      'dataNascimento': dataNascimento.toIso8601String(),
      'notas': notas,
    };
  }

  /// Cria um Aluno a partir de um `Map<String, dynamic>` (vindo do JSON).
  factory Aluno.fromJson(Map<String, dynamic> json) {
    return Aluno(
      id: json['id'] as String,
      nome: json['nome'] as String,
      curso: json['curso'] as String,
      turmaAno: json['turmaAno'] as int,
      apelido: json['apelido'] as String? ?? '',
      dataNascimento: DateTime.parse(json['dataNascimento'] as String),
      notas: (json['notas'] as Map<String, dynamic>).map(
        (key, value) => MapEntry(key, value as int),
      ),
    );
  }

  /// Cria uma cópia deste Aluno, opcionalmente alterando alguns campos.
  Aluno copyWith({
    String? nome,
    String? curso,
    int? turmaAno,
    String? apelido,
    DateTime? dataNascimento,
    Map<String, int>? notas,
  }) {
    return Aluno(
      id: id,
      nome: nome ?? this.nome,
      curso: curso ?? this.curso,
      turmaAno: turmaAno ?? this.turmaAno,
      apelido: apelido ?? this.apelido,
      dataNascimento: dataNascimento ?? this.dataNascimento,
      notas: notas ?? Map.from(this.notas),
    );
  }

  @override
  String toString() {
    return 'Aluno{id: $id, nome: $nome, curso: $curso, turmaAno: $turmaAno, nivelLenda: $nivelLenda}';
  }
}
