import 'dart:convert';
import 'dart:io';

import 'package:dart_frog/dart_frog.dart';
import 'package:ollama_talk_server/ollama_talk_server.dart';

// curl http://localhost:8080/chat
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
  final client = context.read<OllamaTalkServer>();
  final list = await client.loadChatList();

  final data = list.map((e) => e.toSummary()).map((e) => e.toJson()).toList();

  return Response.json(
    body: {'chat_list': jsonEncode(data)},
  );
}
