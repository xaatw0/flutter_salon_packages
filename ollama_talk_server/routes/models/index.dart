import 'dart:convert';
import 'dart:io';

import 'package:dart_frog/dart_frog.dart';
import 'package:ollama_talk_common/ollama_talk_common.dart';
import 'package:ollama_talk_server/ollama_talk_server.dart';

/// curl http://localhost:11434/api/tags
/// curl http://localhost:8080/models
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
  final client = context.read<TalkServer>();
  final llmModels = client.loadLocalLlmModels();
  final embeddedModels = client.loadLocalEmbeddingModels();

  return Response.json(
    body: {
      'llmModels':
          json.encode((await llmModels).map((e) => LlmModel(e())).toList()),
      'embeddedModels': json.encode(
          (await embeddedModels).map((e) => EmbeddingModel(e())).toList())
    },
  );
}
