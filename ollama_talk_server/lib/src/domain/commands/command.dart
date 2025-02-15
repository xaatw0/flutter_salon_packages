import 'dart:async';

abstract interface class ICommand<TInput, TOutput> {
  FutureOr<TOutput> execute(TInput data);
}
