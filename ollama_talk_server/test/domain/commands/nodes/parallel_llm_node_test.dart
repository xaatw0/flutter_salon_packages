import 'package:ollama_talk_server/src/domain/commands/llm_command.dart';
import 'package:ollama_talk_server/src/domain/commands/llm_models/gemini_model.dart';
import 'package:ollama_talk_server/src/domain/commands/nodes/parallel_llm_node.dart';
import 'package:test/test.dart';

void main() {
  test('ParallelLlmNode', () async {
    final parallelLlmNode = ParallelLlmNode(
        GeminiModel(),
        '合計して(結果のみ出力)',
        LlmCommand(GeminiModel(), '1を足す(結果のみ出力)'),
        LlmCommand(GeminiModel(), '2を掛ける(結果のみ出力)'),
        LlmCommand(GeminiModel(), '3を足す(結果のみ出力)'));

    final result = await parallelLlmNode.execute('1');
    expect(result.trim(), (1 + 1 + 1 * 2 + 1 + 3).toString());

    final result5 = await parallelLlmNode.execute('5');
    expect(result5.trim(), (5 + 1 + 5 * 2 + 5 + 3).toString());
  });
}
