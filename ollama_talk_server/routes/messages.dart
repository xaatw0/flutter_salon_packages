import 'dart:convert';
import 'dart:io';

import 'package:dart_frog/dart_frog.dart';
import 'package:ollama_talk_server/ollama_talk_server.dart';

Future<Response> onRequest(RequestContext context) async {
  try {
    return switch (context.request.method) {
      HttpMethod.get => _onGet(context),
      _ => Future.value(Response(statusCode: HttpStatus.methodNotAllowed)),
    };
  } catch (e, st) {
    return Future.value(Response(
      statusCode: HttpStatus.internalServerError,
      body: e.toString() + '\n' + st.toString(),
    ));
  }
}

Response _onGet(RequestContext context) {
  final server = context.read<TalkServer>();
  final list = server.loadMessagesInChat();
  final json = list.map((e) => e.chat.target?.id ?? 0).toList();
  return Response.json(
    body: {'message': json.last},
  );
}
