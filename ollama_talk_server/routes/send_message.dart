import 'dart:async';
import 'dart:convert';

import 'package:dart_frog/dart_frog.dart';
import 'package:dart_frog_web_socket/dart_frog_web_socket.dart';
import 'package:ollama_talk_server/ollama_talk_server.dart';
import 'package:ollama_talk_common/ollama_talk_common.dart';

Future<Response> onRequest(RequestContext context) async {
  final client = context.read<OllamaTalkClient>();

  final completer = Completer<SendChatMessageEntity>();

  final handler = webSocketHandler((clientChannel, protocol) async {
    // Revive prompt from client
    clientChannel.stream.listen((data) {
      if (completer.isCompleted) {
        throw Exception('Data must set only once.');
      }

      completer.complete(SendChatMessageEntity.fromJson(jsonDecode(data)));
    });

    final sendChatMessage = await completer.future;

    final chat = await client.loadChat(sendChatMessage.chatId);
    if (chat == null) {
      throw Exception('No specified chat: chatId=${sendChatMessage.chatId}');
    }

    final streamToLLM =
        client.sendMessageAndWaitResponse(chat, sendChatMessage.prompt);

    // send message from Ollama server to client
    streamToLLM.listen(
      (data) => clientChannel.sink.add(data),
      onDone: () => clientChannel.sink.close(),
    );
  });

  return handler(context);
}
