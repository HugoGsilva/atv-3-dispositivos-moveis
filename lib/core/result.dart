/// Resultado de uma operação. [T] é o tipo do dado em caso de sucesso.
/// Só pode ser [Success] ou [Failure].
sealed class Result<T> {
  const Result();
}

/// Operação bem-sucedida, contendo o [value] retornado.
class Success<T> extends Result<T> {
  final T value;
  const Success(this.value);
}

/// Operação que falhou, contendo a [message] de erro.
class Failure<T> extends Result<T> {
  final String message;
  const Failure(this.message);
}
