// =============================================================================
// 📦 RESULT - Padrão Result (Encapsulamento de Retorno)
// =============================================================================
//
// 🎓 EXPLICAÇÃO PARA APRESENTAÇÃO:
// ---------------------------------
// O padrão Result resolve um problema comum: "Como sabemos se uma operação
// deu certo ou errado?"
//
// SEM Result (jeito ruim):
//   try {
//     final aluno = buscarAluno('123');  // Pode lançar exceção!
//   } catch (e) {
//     print('Erro!');
//   }
//   Problema: nada OBRIGA o programador a tratar o erro.
//
// COM Result (jeito bom):
//   final resultado = buscarAluno('123');  // Retorna Result<Aluno>
//   resultado é OBRIGATORIAMENTE Success ou Failure
//   O programador é FORÇADO a verificar se deu certo ou não.
//
// É como um envelope de carta:
//   - Se der certo, dentro do envelope tem a resposta (Success)
//   - Se der errado, dentro do envelope tem a explicação do erro (Failure)
//
// "sealed class" significa que NINGUÉM pode criar outras subclasses além
// de Success e Failure. Isso garante que só existem 2 possibilidades.
// =============================================================================

/// Classe selada (sealed) que representa o resultado de uma operação.
/// [T] é o tipo do dado em caso de sucesso.
///
/// Só pode ser [Success] ou [Failure].
sealed class Result<T> {
  const Result();
}

/// Representa uma operação que deu CERTO.
/// Contém o [value] com o dado retornado.
///
/// Exemplo: `Success<Aluno>(aluno)` → operação bem-sucedida com o aluno dentro.
class Success<T> extends Result<T> {
  final T value;
  const Success(this.value);
}

/// Representa uma operação que DEU ERRADO.
/// Contém a [message] explicando o que aconteceu.
///
/// Exemplo: Failure('Aluno não encontrado') → operação falhou com essa mensagem.
class Failure<T> extends Result<T> {
  final String message;
  const Failure(this.message);
}
