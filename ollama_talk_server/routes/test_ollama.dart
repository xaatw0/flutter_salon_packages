import 'dart:io';

import 'package:dart_frog/dart_frog.dart';
import 'package:ollama_talk_server/ollama_talk_server.dart';

Future<Response> onRequest(RequestContext context) {
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
  final ollama = context.read<OllamaTalkClient>();
  final models = await ollama.loadLocalModels();
  final modelNames = models.map((e) => e.name).toList();
  return Response.json(
    body: {
      'message': 'success',
      'models': [await modelNames]
    },
  );
}
