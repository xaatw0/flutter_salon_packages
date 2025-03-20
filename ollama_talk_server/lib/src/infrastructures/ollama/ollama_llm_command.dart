import 'dart:async';

import 'package:ollama_talk_server/src/infrastructures/ollama/ollama_llm_model.dart';
import 'package:ollama_talk_server/src/infrastructures/ollama/ollama_server.dart';

import '../../domain/commands/llm_models/llm_model.dart';

class OllamaLlmCommand implements ILlmCommand {
  static const kNoMessageInResponse = '[No Message]';

  const OllamaLlmCommand(this.server, this.ollamaLlmModel);

  final OllamaServer server;
  final OllamaLlmModel ollamaLlmModel;

  @override
  Future<String> execute(String data) async {
    final response = await server.generateWithFuture(ollamaLlmModel(), data);
    return response.response ?? kNoMessageInResponse;
  }
}
