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

    final chatRequestMessage =
        ChatRequestMessage(role: Role.user.name, content: prompt);

    final chatRequest =
        ChatRequestData(model: model(), messages: [chatRequestMessage]);

    final responseModelStream = await llmServer.chat(chatRequest);

    final stream = StreamController<String>();
    final buffer = StringBuffer();
    stream.stream.listen((data) {
      buffer.write(data);
    });
    await for (final ChatResponseData data in responseModelStream) {
      final responseMessage = data.message?.content;
      if (responseMessage == null) {
        continue;
      }

      stream.sink.add(responseMessage);

      if (data.done) {
        stream.close();
      }
    }

    final completer = Completer();
    await completer.future;
    print('-----test1');
    final responseMessage = ''; //responseFromLlmServer.message?.content ?? '';
    final messageForNextAgent = switch (handleReplies) {
      HandleReplies.replace => responseMessage,
      HandleReplies.append => message + '\n' + responseMessage,
    };

    return AgentResponse(messageForNextAgent, handle: handleReplies);
  }
}
