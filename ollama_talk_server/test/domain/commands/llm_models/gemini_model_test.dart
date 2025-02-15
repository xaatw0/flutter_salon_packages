import 'package:ollama_talk_server/src/domain/commands/llm_models/gemini_model.dart';
import 'package:test/test.dart';

void main() {
  test('agent', () async {
    final model = GeminiModel();
    final message = await model.execute('Say only Hello!');
    expect(message.trim(), 'Hello!');
  });
}
