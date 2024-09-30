import 'dart:io';

import 'package:dart_frog/dart_frog.dart';
import 'package:ollama_talk_common/ollama_talk_common.dart';
import 'package:ollama_talk_server/ollama_talk_server.dart';

Future<Response> onRequest(RequestContext context, String model) async {
  return switch (context.request.method) {
    HttpMethod.get => _onGet(context, model),
    _ => Future.value(Response(statusCode: HttpStatus.methodNotAllowed)),
  };
}

Future<Response> _onGet(RequestContext context, String model) async {
  final client = context.read<TalkServer>();
  final modelInfo = await client.showModelInformation(LlmModel(model));
  print(modelInfo.details.quantizationLevel);
  return Response.json(
    body: {'message': 'Success'},
  );
}
