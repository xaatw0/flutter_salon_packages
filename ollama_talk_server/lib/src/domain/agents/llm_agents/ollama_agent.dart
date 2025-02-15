import 'dart:async';

import 'package:ollama_talk_server/src/domain/command.dart';
import 'package:ollama_talk_server/src/infrastructures/ollama/ollama_server.dart';

class OllamaAgent implements ICommand<String, String> {
  static const kModelName = '';
  static const kNoMessageInResponse = '[No Message]';

  const OllamaAgent(this.server);

  final OllamaServer server;

  @override
  FutureOr<String> execute(String data) async {
    final response = await server.generateWithFuture(kModelName, data);
    return response.response ?? kNoMessageInResponse;
  }
}
