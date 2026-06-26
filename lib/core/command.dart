// =============================================================================
// 🎯 COMMAND - Padrão Command (Encapsulamento de Ações)
// =============================================================================
//
// 🎓 EXPLICAÇÃO PARA APRESENTAÇÃO:
// ---------------------------------
// O padrão Command encapsula uma AÇÃO como um objeto.
//
// Imagine um controle remoto de TV:
//   - Cada botão é um "Command"
//   - Quando você aperta o botão, ele EXECUTA a ação
//   - Enquanto executa, o LED pisca (loading)
//   - Se der certo, a TV responde
//   - Se der erro, o LED fica vermelho
//
// No app, o Command faz isso:
//   1. Controla se a ação está executando (loading/running)
//   2. Armazena o resultado (sucesso ou erro)
//   3. Impede execuções duplas (não aperta o botão 2x)
//
// Usamos Flutter Signals para tornar tudo REATIVO:
//   - Quando "running" muda de false para true, a UI mostra loading
//   - Quando "result" recebe um valor, a UI mostra o resultado
//
// Command0 = comando SEM parâmetros (ex: "carregar todos os alunos")
// Command1 = comando COM 1 parâmetro (ex: "salvar este aluno")
// =============================================================================

import 'package:signals_flutter/signals_flutter.dart';
import 'result.dart';

/// Command SEM parâmetros.
/// [R] é o tipo de retorno em caso de sucesso.
///
/// Exemplo de uso:
/// ```dart
/// final carregarCommand = Command0(() async {
///   return facade.buscarTodos();
/// });
///
/// // Na UI:
/// ElevatedButton(
///   onPressed: () => carregarCommand.execute(),
///   child: Text('Carregar'),
/// );
/// ```
class Command0<R> {
  /// Função que será executada quando o command for disparado.
  /// Retorna um `Result<R>` (pode ser Success ou Failure).
  final Future<Result<R>> Function() _action;

  /// Signal reativo: indica se o command está executando.
  /// A UI pode observar isso para mostrar um loading spinner.
  final running = signal<bool>(false);

  /// Signal reativo: armazena o último resultado da execução.
  /// Pode ser null (ainda não executou), Success ou Failure.
  final result = signal<Result<R>?>(null);

  /// Signal reativo: armazena a mensagem de erro, se houver.
  final error = signal<String?>(null);

  Command0(this._action);

  /// Executa a ação encapsulada neste Command.
  ///
  /// Fluxo:
  /// 1. Se já está executando, não faz nada (evita duplo clique)
  /// 2. Marca running = true (UI mostra loading)
  /// 3. Executa a ação
  /// 4. Guarda o resultado
  /// 5. Se deu erro, guarda a mensagem de erro
  /// 6. Marca running = false (UI esconde loading)
  Future<void> execute() async {
    if (running.value) return; // Proteção contra duplo clique

    running.value = true;
    error.value = null;

    try {
      final res = await _action();
      result.value = res;

      // Se o resultado foi um Failure, extraímos a mensagem de erro
      if (res is Failure<R>) {
        error.value = res.message;
      }
    } catch (e) {
      // Se deu uma exceção inesperada, transformamos em Failure
      result.value = Failure<R>(e.toString());
      error.value = e.toString();
    } finally {
      running.value = false;
    }
  }
}

/// Command COM 1 parâmetro.
/// [R] é o tipo de retorno, [A] é o tipo do argumento.
///
/// Exemplo de uso:
/// ```dart
/// final salvarCommand = Command1((aluno) async {
///   return facade.cadastrar(aluno);
/// });
///
/// // Na UI:
/// ElevatedButton(
///   onPressed: () => salvarCommand.execute(meuAluno),
///   child: Text('Salvar'),
/// );
/// ```
class Command1<R, A> {
  /// Função que recebe um argumento do tipo [A] e retorna `Result[R]`.
  final Future<Result<R>> Function(A) _action;

  final running = signal<bool>(false);
  final result = signal<Result<R>?>(null);
  final error = signal<String?>(null);

  Command1(this._action);

  /// Executa a ação passando o argumento [arg].
  /// Funciona igual ao Command0, mas recebe um parâmetro.
  Future<void> execute(A arg) async {
    if (running.value) return;

    running.value = true;
    error.value = null;

    try {
      final res = await _action(arg);
      result.value = res;

      if (res is Failure<R>) {
        error.value = res.message;
      }
    } catch (e) {
      result.value = Failure<R>(e.toString());
      error.value = e.toString();
    } finally {
      running.value = false;
    }
  }
}
