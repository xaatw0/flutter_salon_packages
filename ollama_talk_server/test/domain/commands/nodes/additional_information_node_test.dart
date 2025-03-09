import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:ollama_talk_server/src/domain/commands/llm_command.dart';
import 'package:ollama_talk_server/src/domain/commands/llm_models/gemini_model.dart';
import 'package:ollama_talk_server/src/domain/commands/nodes/additional_information_node.dart';
import 'package:test/test.dart';

import 'additional_information_node_test.mocks.dart';

@GenerateNiceMocks([MockSpec<LlmCommand>()])
void main() {
  test('AdditionalInformationNode', () async {
    final prompt = '坂本龍馬の誕生日は西暦で何年ですか(数字のみ)';

    final mockRag = MockLlmCommand();
    when(mockRag.execute(prompt)).thenAnswer((_) async =>
        '坂本 龍馬（さかもと りょうま、天保6年11月15日〈1836年1月3日〉 - 慶応3年11月15日〈1867年12月10日〉）は、日本の幕末の土佐藩士、志士、経営者。');

    final target = AdditionalInformationNode(
      GeminiModel(),
      mockRag,
    );

    final response = await target.execute(prompt);
    expect(response.trim(), '1836');
  });
}
