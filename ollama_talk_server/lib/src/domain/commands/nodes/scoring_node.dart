import 'dart:async';

import 'package:ollama_talk_server/src/domain/commands/command.dart';

import '../llm_command.dart';

class ScoringNode implements ICommand<List<String>, List<int?>> {
  const ScoringNode(this.command);

  final LlmCommand command;

  @override
  Future<List<int?>> execute(List<String> data) async {
    return Future.wait(data
        .map((e) => command.execute(e))
        .map((e) async => int.tryParse(await e)));
  }
}
