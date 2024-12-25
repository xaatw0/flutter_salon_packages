import 'dart:async';
import 'dart:convert';

import 'package:dart_frog/dart_frog.dart';
import 'package:dart_frog_web_socket/dart_frog_web_socket.dart';
import 'package:ollama_talk_server/ollama_talk_server.dart';
import 'package:ollama_talk_common/ollama_talk_common.dart';
import 'package:ollama_talk_server/src/domain/agents/abstract_agent.dart';
import 'package:ollama_talk_server/src/domain/agents/llm_agent.dart';

Future<Response> onRequest(RequestContext context) async {
  final client = context.read<TalkServer>();
  final completer = Completer<SendChatMessageEntity>();

  final handler = webSocketHandler((clientChannel, protocol) async {
    clientChannel.stream.listen((data) {
      if (completer.isCompleted) {
        throw Exception('Data must set only once.');
      }

      completer.complete(SendChatMessageEntity.fromJson(jsonDecode(data)));
    });

    // wait for message from client
    final sendChatMessage = await completer.future;

    final chat = await client.loadChat(sendChatMessage.chatId);
    if (chat == null) {
      throw Exception('No specified chat: chatId=${sendChatMessage.chatId}');
    } else if (chat.title.isEmpty) {
      chat.title = sendChatMessage.prompt;
    }

    final agents =
        LlmAgent(LlmModel(chat.llmModel), '愛情たっぷりに表現して', HandleReplies.replace);
    final agentResponse = await agents.input(sendChatMessage.prompt);
    clientChannel.sink.add(agentResponse.message);
    clientChannel.sink.close();
  });

  return handler(context);
}
