import 'dart:io';

import 'package:dart_frog/dart_frog.dart';
import 'package:ollama_talk_server/ollama_talk_server.dart';

//
Future<Response> onRequest(RequestContext context) async {
  try {
    return switch (context.request.method) {
      HttpMethod.post => _onPost(context),
      _ => Future.value(Response(statusCode: HttpStatus.methodNotAllowed)),
    };
  } catch (e) {
    return Future.value(Response(
      statusCode: HttpStatus.internalServerError,
      body: e.toString(),
    ));
  }
}

Future<Response> _onPost(RequestContext context) async {
  final formData = await context.request.formData();
  final prompt = formData.fields['prompt'];
  if (prompt == null) {
    return Response.json(
        statusCode: HttpStatus.badRequest,
        body: {'message': 'prompt not found'});
  }

  final chatId = int.tryParse(formData.fields['id'] ?? '');
  if (chatId == null) {
    return Response.json(
        statusCode: HttpStatus.badRequest,
        body: {'message': 'id not found or not number format'});
  }

  final client = context.read<TalkServer>();

  final chat = await client.loadChat(chatId);
  if (chat == null) {
    throw Exception('No specified chat: chatId=$chatId');
  } else if (chat.title.isEmpty) {
    chat.title = 'no title';
  }

  final result = client.sendMessageWithoutStream(chat, prompt);

  return Response.json(
    body: {'message': result},
  );
}
