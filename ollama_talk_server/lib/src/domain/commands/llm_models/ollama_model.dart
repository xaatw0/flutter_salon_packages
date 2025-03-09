import 'dart:async';

import 'package:ollama_talk_server/src/infrastructures/ollama/ollama_server.dart';

import 'llm_model.dart';

class OllamaModel implements ILlmModel {
  static const kModelName = 'elyza:jp8b';
  static const kNoMessageInResponse = '[No Message]';

  const OllamaModel(this.server);

  final OllamaServer server;

  @override
  Future<String> execute(String data) async {
    final response = await server.generateWithFuture(kModelName, data);
    return response.response ?? kNoMessageInResponse;
  }
}
