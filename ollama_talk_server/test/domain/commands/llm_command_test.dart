import 'package:ollama_talk_server/src/domain/commands/llm_command.dart';
import 'package:ollama_talk_server/src/domain/commands/llm_models/gemini_model.dart';
import 'package:test/test.dart';

void main() {
  test('訳す', () async {
    final command = LlmCommand(GeminiModel(), '日本語訳して');
    final result = await command.execute('Hello');
    expect(result.trim(), 'こんにちは');
  });
}
