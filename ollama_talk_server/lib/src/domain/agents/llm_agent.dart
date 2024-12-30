import 'dart:async';

import 'package:ollama_talk_common/ollama_talk_common.dart';
import 'package:ollama_talk_server/ollama_talk_server.dart';
import 'package:ollama_talk_server/src/domain/agents/abstract_agent.dart';

import '../service_locator.dart';

class LlmAgent extends AbstractAgent {
  LlmAgent(this.model, this.prompt, this.handleReplies);

  final LlmModel model;
  final String prompt;
  final HandleReplies handleReplies;

  @override
  Future<AgentResponse> process(String message) async {
    final llmServer = ServiceLocator.instance.ollamaServer;

    final messageEntity = MessageEntity(Role.user, message);

    final chatRequest = ChatRequestData(
        model: model(), messages: [ChatRequestMessage.fromData(messageEntity)]);

    final response = await llmServer.chatWithoutStream(chatRequest);

    final responseMessage = response.message?.content ?? message;
    final messageForNextAgent = switch (handleReplies) {
      HandleReplies.replace => responseMessage,
      HandleReplies.append => '''{"question": "$message",
            "answer": "$responseMessage"}''',
    };

    return AgentResponse(messageForNextAgent, handle: handleReplies);
  }
}
