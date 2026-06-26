// =============================================================================
// 👤 ALUNO - Model (Camada de Domínio)
// =============================================================================
//
// 🎓 EXPLICAÇÃO PARA APRESENTAÇÃO:
// ---------------------------------
// O Model é a representação dos DADOS do app. Pense nele como uma "ficha
// cadastral" digital.
//
// Esta classe Aluno contém:
//   - Dados cadastrais: nome, curso, turma/ano, apelido, data de nascimento
//   - Notas: um Map com os 15 critérios e suas notas (1 a 5)
//   - ID: identificador único gerado automaticamente (UUID)
//
// Métodos importantes:
//   - nivelLenda: soma todas as notas (propriedade computada/calculada)
//   - toJson(): converte o aluno para Map (para salvar no SharedPreferences)
//   - fromJson(): cria um Aluno a partir de um Map (para ler do SharedPreferences)
//   - copyWith(): cria uma CÓPIA do aluno com algumas alterações
//
// Por que copyWith()?
//   Em Dart, objetos são passados por referência. Se modificarmos diretamente,
//   podemos causar bugs. copyWith() cria uma cópia nova e segura.
//   É como tirar uma xerox e escrever na xerox, mantendo o original intacto.
// =============================================================================

import 'package:uuid/uuid.dart';
import '../../core/constants.dart';

/// Modelo que representa um Aluno cadastrado no sistema.
///
/// Cada aluno possui dados cadastrais e notas em 15 critérios de popularidade.
/// A soma das notas forma o "Nível Lenda" (15 a 75 pontos).
class Aluno {
  /// Identificador único do aluno (UUID v4).
  /// Gerado automaticamente no cadastro.
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

  /// Notas dos 15 critérios de popularidade.
  /// Chave = ID do critério (ex: 'resenha'), Valor = nota de 1 a 5.
  ///
  /// Exemplo:
  /// {
  ///   'resenha': 4,
  ///   'presenca_vip': 3,
  ///   'aura': 5,
  ///   ...
  /// }
  final Map<String, int> notas;

  Aluno({
    String? id, // Se não passar, gera um novo UUID
    required this.nome,
    required this.curso,
    required this.turmaAno,
    this.apelido = '',
    required this.dataNascimento,
    Map<String, int>? notas,
  })  : id = id ?? const Uuid().v4(),
        // Se não passar notas, inicializa todos os critérios com 1 estrela
        notas = notas ??
            {for (final c in kCriterios) c['id']!: kNotaMinima};

  // ===========================================================================
  // PROPRIEDADES CALCULADAS (Computed Properties)
  // ===========================================================================

  /// Nível Lenda = soma de todas as notas dos 15 critérios.
  /// Mínimo: 15 (todos com 1 estrela)
  /// Máximo: 75 (todos com 5 estrelas)
  ///
  /// "get" significa que é uma propriedade calculada sob demanda.
  /// Cada vez que acessamos aluno.nivelLenda, ele recalcula a soma.
  int get nivelLenda => notas.values.fold(0, (soma, nota) => soma + nota);
  //                    ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
  //                    fold() percorre todos os valores e acumula a soma.
  //                    Começa com 0 e vai somando cada nota.

  // ===========================================================================
  // SERIALIZAÇÃO (Converter para/de JSON)
  // ===========================================================================
  //
  // 🎓 POR QUE PRECISAMOS DISSO?
  // SharedPreferences só salva tipos simples (String, int, bool).
  // Para salvar um objeto Aluno, precisamos convertê-lo para JSON (String).
  //
  // Fluxo de SALVAR: Aluno → toJson() → Map → jsonEncode → String → SharedPrefs
  // Fluxo de LER:    SharedPrefs → String → jsonDecode → Map → fromJson() → Aluno
  // ===========================================================================

  /// Converte este Aluno para um `Map<String, dynamic>` (formato JSON).
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nome': nome,
      'curso': curso,
      'turmaAno': turmaAno,
      'apelido': apelido,
      // DateTime não é serializável diretamente, então convertemos
      // para ISO 8601 string (ex: "2005-03-15T00:00:00.000")
      'dataNascimento': dataNascimento.toIso8601String(),
      'notas': notas,
    };
  }

  /// Cria um Aluno a partir de um `Map<String, dynamic>` (vindo do JSON).
  ///
  /// "factory" é um construtor especial que pode retornar uma instância
  /// já existente ou fazer lógica antes de criar o objeto.
  factory Aluno.fromJson(Map<String, dynamic> json) {
    return Aluno(
      id: json['id'] as String,
      nome: json['nome'] as String,
      curso: json['curso'] as String,
      turmaAno: json['turmaAno'] as int,
      apelido: json['apelido'] as String? ?? '',
      dataNascimento: DateTime.parse(json['dataNascimento'] as String),
      // O JSON decodifica como Map<String, dynamic>, precisamos converter
      // cada valor para int
      notas: (json['notas'] as Map<String, dynamic>)
          .map((key, value) => MapEntry(key, value as int)),
    );
  }

  // ===========================================================================
  // COPY WITH (Cópia com Modificações)
  // ===========================================================================
  //
  // 🎓 POR QUE USAR copyWith()?
  // Em vez de modificar o objeto diretamente (o que pode causar bugs),
  // criamos uma CÓPIA com os campos alterados.
  //
  // Exemplo:
  //   final alunoAtualizado = aluno.copyWith(nome: 'Novo Nome');
  //   // aluno original NÃO mudou!
  //   // alunoAtualizado tem o nome novo, mas todos os outros dados iguais.
  // ===========================================================================

  /// Cria uma cópia deste Aluno, opcionalmente alterando alguns campos.
  /// Campos não informados mantêm o valor original.
  Aluno copyWith({
    String? nome,
    String? curso,
    int? turmaAno,
    String? apelido,
    DateTime? dataNascimento,
    Map<String, int>? notas,
  }) {
    return Aluno(
      id: id, // O ID nunca muda
      nome: nome ?? this.nome,
      curso: curso ?? this.curso,
      turmaAno: turmaAno ?? this.turmaAno,
      apelido: apelido ?? this.apelido,
      dataNascimento: dataNascimento ?? this.dataNascimento,
      notas: notas ?? Map.from(this.notas), // Copia o Map para segurança
    );
  }

  @override
  String toString() {
    return 'Aluno{id: $id, nome: $nome, curso: $curso, turmaAno: $turmaAno, nivelLenda: $nivelLenda}';
  }
}
