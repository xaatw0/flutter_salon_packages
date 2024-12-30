import 'dart:convert';
import 'dart:io';

import 'package:dart_frog/dart_frog.dart';
import 'package:ollama_talk_common/ollama_talk_common.dart';
import 'package:ollama_talk_server/ollama_talk_server.dart';

/// List llm models and embedding models in OllamaServer.
/// from ollama: curl http://localhost:11434/api/tags,  curl http://127.0.0.1:11434/api/tags
/// from OllamaTalkServer: curl http://localhost:8080/models
Future<Response> onRequest(RequestContext context) async {
  try {
    return switch (context.request.method) {
      HttpMethod.get => _onGet(context),
      _ => Future.value(Response(statusCode: HttpStatus.methodNotAllowed)),
    };
  } catch (e) {
    return Future.value(Response(
      statusCode: HttpStatus.internalServerError,
      body: e.toString(),
    ));
  }
}

Future<Response> _onGet(RequestContext context) async {
  print('test1');

  final client = context.read<TalkServer>();
  print('test2');
  final llmModels = await client.loadLocalLlmModels();
  print('test3');
  final embeddedModels = await client.loadLocalEmbeddingModels();
  print('test4');

  return Response.json(
    body: {
      'llmModels':
          json.encode((await llmModels).map((e) => LlmModel(e())).toList()),
      'embeddedModels': json.encode(
          (await embeddedModels).map((e) => EmbeddingModel(e())).toList())
    },
  );
}
