import 'package:ollama_talk_server/src/domain/agents/llm_agents/gemini_agent.dart';
import 'package:test/test.dart';

void main() {
  test('agent', () async {
    final agent = GeminiAgent();
    final message = await agent.execute('Say only Hello!');
    expect(message.trim(), 'Hello!');
  });
}
