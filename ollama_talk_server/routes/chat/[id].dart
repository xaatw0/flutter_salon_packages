import 'dart:io';

import 'package:dart_frog/dart_frog.dart';
import 'package:ollama_talk_server/ollama_talk_server.dart';

/// curl http://localhost:8080/models
Future<Response> onRequest(RequestContext context, String id) async {
  return switch (context.request.method) {
    HttpMethod.get => _onGet(context, int.parse(id)),
    _ => Future.value(Response(statusCode: HttpStatus.methodNotAllowed)),
  };
}

Future<Response> _onGet(RequestContext context, int chatId) async {
  final client = context.read<TalkServer>();

  final chat = await client.loadChat(chatId);
  if (chat == null) {
    return Response(statusCode: HttpStatus.notFound);
  }

  return Response.json(body: chat.toChatModel());
}
