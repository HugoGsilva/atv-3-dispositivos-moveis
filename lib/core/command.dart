import 'package:signals_flutter/signals_flutter.dart';
import 'result.dart';

/// Command sem parâmetros. [R] é o tipo de retorno em caso de sucesso.
class Command0<R> {
  final Future<Result<R>> Function() _action;

  final running = signal<bool>(false);
  final result = signal<Result<R>?>(null);
  final error = signal<String?>(null);

  Command0(this._action);

  Future<void> execute() async {
    if (running.value) return; // evita duplo clique

    running.value = true;
    error.value = null;

    try {
      final res = await _action();
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

/// Command com 1 parâmetro. [R] é o tipo de retorno, [A] o tipo do argumento.
class Command1<R, A> {
  final Future<Result<R>> Function(A) _action;

  final running = signal<bool>(false);
  final result = signal<Result<R>?>(null);
  final error = signal<String?>(null);

  Command1(this._action);

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
