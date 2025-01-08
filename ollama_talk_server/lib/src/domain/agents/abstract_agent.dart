import 'dart:async';

abstract class AbstractAgent {
  Future<AgentResponse> process(String message);

  AbstractAgent? nextAgent;

  Future<AgentResponse> input(String message) async {
    final response = await process(message);
    if (nextAgent == null) {
      return response;
    }

    return nextAgent!.input(response.message);
  }

  void setNext(AbstractAgent nextAgent) {
    var agentWithoutNext = this;
    for (;
        agentWithoutNext.nextAgent != null;
        agentWithoutNext = agentWithoutNext.nextAgent!);
    agentWithoutNext.nextAgent = nextAgent;
  }
}

enum HandleReplies {
  append(),
  replace();

  const HandleReplies();
}

class AgentResponse {
  const AgentResponse(this.message, {required this.handle});
  final String message;
  final HandleReplies handle;
}
