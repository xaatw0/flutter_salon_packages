import 'package:ollama_talk_server/src/domain/commands/llm_command.dart';
import 'package:ollama_talk_server/src/domain/commands/llm_models/gemini_model.dart';
import 'package:ollama_talk_server/src/domain/commands/nodes/sequential_llm_command.dart';
import 'package:ollama_talk_server/src/domain/commands/trim_json_command.dart';
import 'package:test/test.dart';

void main() {
  test('model', () async {
    final model = GeminiModel();
    final message = await model.execute('Say only Hello!');
    expect(message.trim(), 'Hello!');
  });

  test('sequential', () async {
    final command1 = LlmCommand(GeminiModel(), '日本語訳して');
    final command2 = LlmCommand(GeminiModel(), '「ござる」をつけて\n例: こんにちは→こんにちはでござる');
    final command3 = LlmCommand(
      GeminiModel(),
      '以下のJSONフォーマットに整形\n{"message":"(content)"',
    );

    final result =
        await SequentialLlmCommand(command1, command2).execute('Hello');
    expect(result.trim(), 'こんにちはでござる');
  });

  test('json', () async {
    final command1 = LlmCommand(GeminiModel(), '日本語訳して');
    final command2 = LlmCommand(GeminiModel(), '「ござる」をつけて\n例: こんにちは→こんにちはでござる');
    final command3 = LlmCommand(
      GeminiModel(),
      '以下のJSONフォーマットに整形\n{"message":"(content)"',
    );

    final result = await SequentialLlmCommand(
            command1, command2, command3, TrimJsonCommand())
        .execute('Hello');
    expect(
      result.replaceAll('\n', '').replaceAll(' ', ''),
      '{"message":"こんにちはでござる"}',
    );
  });
}
