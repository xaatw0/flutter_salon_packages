import 'dart:convert';

import '../service_locator.dart';
import 'abstract_agent.dart';

class RagSelectAgent extends AbstractAgent {
  @override
  Future<AgentResponse> process(String message) async {
    final server = ServiceLocator.instance.ollamaTalkServer;
    final documents = await server.findRelatedInformation(message);
    final list = documents.map((e) => e.message).toList();
    return AgentResponse(
      '{"data": ${jsonEncode(list)}}',
      handle: HandleReplies.replace,
    );
  }
}
