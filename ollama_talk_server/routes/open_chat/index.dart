import 'dart:io';

import 'package:dart_frog/dart_frog.dart';
import 'package:ollama_talk_common/ollama_talk_common.dart';
import 'package:ollama_talk_server/ollama_talk_server.dart';
import 'package:ollama_talk_common/src/value_objects/chat_id.dart';

/// curl  http://localhost:8080/open_chat?model=elyza:jp8b"&"system=%E6%97%A5%E6%9C%AC%E8%AA%9E%E3%81%A7%E7%AD%94%E3%81%88%E3%81%A6
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
  final modelName = context.request.uri.queryParameters['model'];
  final systemMessage = context.request.uri.queryParameters['system'];

  final errorMessage = (modelName == null ? 'No model/' : '') +
      (systemMessage == null ? 'No system/' : '');

  if (errorMessage.isNotEmpty) {
    return Response.json(
      body: {'message': errorMessage.substring(0, errorMessage.length - 1)},
      statusCode: 400,
    );
  }

  final client = context.read<TalkServer>();
  final chat = client.openChat(modelName!, systemMessage!);

  return Response.json(
    body: ChatId((await chat).id).toJson(),
  );
}
