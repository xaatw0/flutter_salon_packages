import 'dart:convert';
import 'dart:io';

import 'package:dart_frog/dart_frog.dart';
import 'package:ollama_talk_server/ollama_talk_server.dart';

/// curl http://localhost:8080/models
Future<Response> onRequest(RequestContext context, String id) async {
  final intId = int.parse(id);
  return switch (context.request.method) {
    HttpMethod.get => _onGet(context, intId),
    HttpMethod.post => _onPost(context, intId),
    _ => Future.value(Response(statusCode: HttpStatus.methodNotAllowed)),
  };
}

Future<Response> _onGet(RequestContext context, int chatId) async {
  final client = context.read<TalkServer>();

  final chat = await client.loadChat(chatId);
  if (chat == null) {
    return Response(statusCode: HttpStatus.notFound);
  }

  return Response.json(body: chat.toChatEntity());
}

Future<Response> _onPost(RequestContext context, int chatId) async {
  final client = context.read<TalkServer>();
  final body = context.request.body();
  final json = jsonDecode(await body) as Map<String, dynamic>;

  var chat = await client.loadChat(chatId);
  if (chat == null) {
    return Response(statusCode: HttpStatus.notFound);
  }

  final title = json['title'];
  if (title != null) {
    chat = await client.updateTitle(chatId, title);
  }

  return Response.json(body: chat!.toChatEntity());
}
