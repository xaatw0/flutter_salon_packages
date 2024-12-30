import 'dart:convert';
import 'dart:io';

import 'package:dart_frog/dart_frog.dart';
import 'package:ollama_talk_common/ollama_talk_common.dart';
import 'package:ollama_talk_server/ollama_talk_server.dart';
import 'package:ollama_talk_server/src/domain/agents/abstract_agent.dart';
import 'package:ollama_talk_server/src/domain/agents/llm_agent.dart';

/// Send message using agents like LlmAgent.
///
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
  final source = await context.request.body();
  final body = jsonDecode(source);
  final prompt = body['prompt'] as String?;
  if (prompt == null) {
    return Response.json(
        statusCode: HttpStatus.badRequest,
        body: {'message': 'prompt not found'});
  }

  final chatId = body['id'] as int?;
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

  final llmModel = LlmModel(chat.llmModel);
  final agents = LlmAgent(llmModel, prompt, HandleReplies.replace);

  final response = await client.sendMessageWithAgent(chat, prompt, agents);

  return Response.json(body: {
    'message': 'ok',
    'data': response,
  });
}
