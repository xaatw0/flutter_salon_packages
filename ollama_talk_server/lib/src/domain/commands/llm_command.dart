import 'dart:async';

import 'package:ollama_talk_server/src/domain/commands/command.dart';

import 'llm_models/llm_model.dart';

enum BasePromptIn {
  Bottom,
  Upper,
}

class LlmCommand implements ICommand<String, String> {
  const LlmCommand(this.model, this.basePrompt,
      {this.promptIn = BasePromptIn.Bottom});

  final ILlmCommand model;

  final String basePrompt;
  final BasePromptIn promptIn;

  @override
  Future<String> execute(String data) {
    final prompt = (promptIn == BasePromptIn.Upper ? basePrompt + '\n\n' : '') +
        data +
        (promptIn == BasePromptIn.Bottom ? '\n\n' + basePrompt : '');
    print('prompt[[$prompt]]');
    return model.execute(prompt);
  }

  @override
  String toString() {
    return 'LlmCommand[model:$model prompt:$basePrompt]';
  }
}
