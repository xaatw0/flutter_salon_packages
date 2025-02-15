import 'dart:async';

import 'package:ollama_talk_server/src/infrastructures/ollama/ollama_server.dart';

import 'llm_model.dart';

class OllamaModel implements ILlmModel {
  static const kModelName = '';
  static const kNoMessageInResponse = '[No Message]';

  const OllamaModel(this.server);

  final OllamaServer server;

  @override
  FutureOr<String> execute(String data) async {
    final response = await server.generateWithFuture(kModelName, data);
    return response.response ?? kNoMessageInResponse;
  }
}
