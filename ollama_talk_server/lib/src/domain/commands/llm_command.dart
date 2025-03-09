import 'dart:async';

import 'package:ollama_talk_server/src/domain/commands/command.dart';

import 'llm_models/llm_model.dart';

class LlmCommand implements ICommand<String, String> {
  const LlmCommand(this.model, this.basePrompt);

  final ILlmModel model;

  final String basePrompt;

  @override
  Future<String> execute(String data) {
    final prompt = '$basePrompt\n----------\n$data';
    return model.execute(prompt);
  }

  @override
  String toString() {
    return 'LlmCommand[model:$model prompt:$basePrompt]';
  }
}
