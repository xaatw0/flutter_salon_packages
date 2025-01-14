import 'dart:async';

import 'package:ollama_talk_common/ollama_talk_common.dart';
import 'package:ollama_talk_server/ollama_talk_server.dart';
import 'package:ollama_talk_server/src/domain/agents/abstract_agent.dart';

import '../service_locator.dart';

class LlmAgent extends AbstractAgent {
  LlmAgent(this.model, this.command);

  final LlmModel model;
  final String command;

  static const kKeyCommand = '%command%';
  static const kKeyInput = '%input%';
  static const kRequestFormatForLlm =
      '{"command":"$kKeyCommand","input":"$kKeyInput"}';

  @override
  Future<AgentResponse> process(String message) async {
    final llmServer = ServiceLocator.instance.ollamaTalkServer.ollamaServer;

    final messageEntity = MessageEntity(
      Role.user,
      kRequestFormatForLlm
          .replaceAll(kKeyCommand, command)
          .replaceAll(kKeyInput, message),
    );

    final chatRequest = ChatRequestData(
        model: model(), messages: [ChatRequestMessage.fromData(messageEntity)]);
    final response = await llmServer.chatWithoutStream(chatRequest);
    final responseMessage = response.message?.content ?? message;

    return AgentResponse(responseMessage, handle: HandleReplies.replace);
  }
}
