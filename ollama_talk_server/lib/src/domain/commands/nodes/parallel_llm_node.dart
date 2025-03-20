import 'dart:async';

import 'package:ollama_talk_server/src/domain/commands/command.dart';

import '../llm_command.dart';
import '../llm_models/llm_model.dart';

class ParallelLlmNode implements ICommand<String, String> {
  static const _kSeparator = '--------';

  const ParallelLlmNode(
    this.model,
    this.basePrompt,
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

  final ILlmCommand model;
  final String basePrompt;
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
    final List<String> response = await Future.wait(
      _commands.map((e) async => e.execute(data)),
    );

    final additional = response.join('$_kSeparator\n');
    final prompt = '$basePrompt\n$_kSeparator\n$additional';
    return model.execute(prompt);
  }
}
