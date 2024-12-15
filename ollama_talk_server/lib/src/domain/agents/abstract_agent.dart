import 'dart:async';

abstract class AbstractAgent {
  Future<AgentResponse> process(String message);

  AbstractAgent? nextAgent;

  Future<AgentResponse> input(String message) async {
    final response = await process(message);
    if (nextAgent == null) {
      return response;
    }

    return nextAgent!.process(response.message);
  }

  AbstractAgent setNext(AbstractAgent nextAgent) {
    this.nextAgent = nextAgent;
    return nextAgent;
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
