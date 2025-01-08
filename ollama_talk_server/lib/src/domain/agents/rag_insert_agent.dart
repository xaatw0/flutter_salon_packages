import 'package:ollama_talk_common/ollama_talk_common.dart';
import 'package:ollama_talk_server/ollama_talk_server.dart';

import '../service_locator.dart';
import 'abstract_agent.dart';

class RagInsertAgent extends AbstractAgent {
  RagInsertAgent(this.llmModel);

  final LlmModel llmModel;

  static const _kPromptForTitle =
      'Create a title for the following sentence. Return only the title. In the language of the sentence. The following is the sentence:';

  @override
  Future<AgentResponse> process(String message) async {
    final talkServer = ServiceLocator.instance.ollamaTalkServer;
    final ollamaServer = talkServer.ollamaServer;
    final prompt = _kPromptForTitle + message;
    final requestData = ChatRequestData(
        model: llmModel(),
        messages: [ChatRequestMessage(role: Role.user.name, content: prompt)]);
    final response = await ollamaServer.chatWithoutStream(requestData);
    final title = response.message?.content ?? 'No title';
    talkServer.insertDocument(title, message);
    return AgentResponse('{"title":"$title"}', handle: HandleReplies.replace);
  }
}
