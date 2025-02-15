import 'package:ollama_talk_server/src/domain/commands/llm_command.dart';
import 'package:ollama_talk_server/src/domain/commands/llm_models/gemini_model.dart';
import 'package:ollama_talk_server/src/domain/commands/nodes/select_one_node.dart';
import 'package:test/test.dart';

void main() {
  group('一番大きい回答を選ぶ', () {
    final command1 = LlmCommand(GeminiModel(), '入力値に10足して(値のみ出力)');
    final command2 = LlmCommand(GeminiModel(), '入力値に5掛けて(値のみ出力)');
    final command3 = LlmCommand(GeminiModel(), '入力値と入力値を掛けて(値のみ出力)');
    final target = SelectOneNode(
        LlmCommand(GeminiModel(), '一番大きな値を回答して(値のみ出力)'),
        [command1, command2, command3]);

    test('1+10=11', () async {
      final response = await target.execute('1');
      expect(response.trim(), '11');
    });

    test('4*5=20', () async {
      final response = await target.execute('4');
      expect(response.trim(), '20');
    });

    test('8*8=64', () async {
      final response = await target.execute('8');
      expect(response.trim(), '64');
    });
  });
}
