import 'dart:io';

import 'package:dart_frog/dart_frog.dart';
import 'package:ollama_talk_server/ollama_talk_server.dart';

/// curl  http://localhost:8080/documents
/// [{"id":1,"fileName":"test.txt","memo":"memo","createDate":"2024-08-14T15:34:49.952"}]%
Future<Response> onRequest(RequestContext context) async {
  return switch (context.request.method) {
    HttpMethod.get => _onGet(context),
    _ => Future.value(Response(statusCode: HttpStatus.methodNotAllowed)),
  };
}

Future<Response> _onGet(RequestContext context) async {
  final client = context.read<TalkServer>();
  final documents = client.getDocuments();
  return Response.json(
    body: (await documents),
  );
}
