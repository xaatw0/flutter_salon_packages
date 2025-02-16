import 'dart:async';

import 'package:ollama_talk_server/src/domain/commands/command.dart';

class SequentialNode<T> implements ICommand<T, T> {
  const SequentialNode(
    this.command1,
    this.command2, [
    this.command3,
    this.command4,
    this.command5,
    this.command6,
    this.command7,
    this.command8,
    this.command9,
  ]);

  final ICommand<T, T> command1;
  final ICommand<T, T> command2;
  final ICommand<T, T>? command3;
  final ICommand<T, T>? command4;
  final ICommand<T, T>? command5;
  final ICommand<T, T>? command6;
  final ICommand<T, T>? command7;
  final ICommand<T, T>? command8;
  final ICommand<T, T>? command9;

  Iterable<ICommand<T, T>> get _commands => [
        command1,
        command2,
        command3,
        command4,
        command5,
        command6,
        command7,
        command8,
        command9
      ].nonNulls;

  @override
  FutureOr<T> execute(T data) async {
    FutureOr<T> result = data;
    for (final command in _commands) {
      result = command.execute(await result);
    }
    return result;
  }
}
