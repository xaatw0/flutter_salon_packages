import 'dart:async';

import 'package:ollama_talk_server/src/domain/commands/llm_command.dart';

import '../command.dart';

class SelectOneNode implements ICommand<String, String> {
  static const _kSeparator = '--------';

  const SelectOneNode(this.command, this.commands);

  final LlmCommand command;
  final List<LlmCommand> commands;

  @override
  FutureOr<String> execute(String data) async {
    final responses = commands.map((e) => e.execute(data));
    final Future<List<String>> options =
        Future.wait(responses.map((e) async => await e));
    return command.execute((await options).join('\n$_kSeparator'));
  }
}
