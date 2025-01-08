import 'package:ollama_talk_server/src/domain/agents/abstract_agent.dart';
import 'package:test/test.dart';

class MockAgent extends AbstractAgent {
  MockAgent(this.name);

  final String name;

  @override
  Future<AgentResponse> process(String message) async {
    return AgentResponse('$name[$message]', handle: HandleReplies.replace);
  }
}

main() {
  group('process, input', () {
    test('single', () async {
      final agent = MockAgent('A');
      final response1 = await agent.process('message1');
      expect(response1.message, 'A[message1]');

      final response2 = await agent.input('message2');
      expect(response2.message, 'A[message2]');
    });

    test('chain', () async {
      final agentA = MockAgent('A');
      final agentB = MockAgent('B');
      final agentC = MockAgent('C');

      final responseA = await agentA.input('message');
      expect(responseA.message, 'A[message]');

      agentA.setNext(agentB);
      final responseAB = await agentA.input('message');
      expect(responseAB.message, 'B[A[message]]');

      agentA.setNext(agentC);
      final responseABC = await agentA.input('message');
      expect(responseABC.message, 'C[B[A[message]]]');
    });

    test('chain2', () async {
      final agents = MockAgent('A')
        ..setNext(MockAgent('B'))
        ..setNext(MockAgent('C'));

      final responseABC = await agents.input('message');
      expect(responseABC.message, 'C[B[A[message]]]');
    });
  });
}
