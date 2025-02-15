import 'dart:async';

import 'package:ollama_talk_server/src/domain/commands/command.dart';

import '../llm_command.dart';

class SequentialLlmCommand implements ICommand<String, String> {
  const SequentialLlmCommand(
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

  final LlmCommand command1;
  final LlmCommand command2;
  final LlmCommand? command3;
  final LlmCommand? command4;
  final LlmCommand? command5;
  final LlmCommand? command6;
  final LlmCommand? command7;
  final LlmCommand? command8;
  final LlmCommand? command9;

  Iterable<LlmCommand> get _commands => [
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
  FutureOr<String> execute(final String data) async {
    FutureOr<String> result = data;
    for (final command in _commands) {
      result = command.execute(await result);
    }
    return result;
  }
}
