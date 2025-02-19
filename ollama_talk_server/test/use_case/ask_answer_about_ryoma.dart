import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:ollama_talk_server/src/domain/commands/llm_command.dart';
import 'package:ollama_talk_server/src/domain/commands/llm_models/gemini_model.dart';
import 'package:ollama_talk_server/src/domain/commands/nodes/additional_information_node.dart';
import 'package:ollama_talk_server/src/domain/commands/nodes/sequential_llm_command.dart';
import 'package:test/test.dart';

import 'ask_answer_about_ryoma.mocks.dart';

@GenerateNiceMocks([MockSpec<LlmCommand>()])
void main() async {
  final info = '土佐藩郷士の家に生まれ、脱藩した後は志士として活動し、貿易会社と政治組織を兼ねた亀山社中（のちの海援隊）を結成した。'
      '薩長同盟の成立に協力するなど、倒幕および明治維新に関与した。'
      '大政奉還成立後の慶応3年11月15日（1867年12月10日）に京都河原町通蛸薬師下ルの近江屋において暗殺された。'
      '実行犯については今井信郎による自供から、京都見廻組によるものという説が有力であるが[2]、異説もある（詳細は「近江屋事件」を参照）。贈正四位。';

  final samuraiTalk = 'ござる口調で話してください 例）でした→だったでござる、した→したでござる';
  final ojoTalk = 'お嬢様口調で話してください 例）でした→でしたわ、した→しましたわ';
  final question = '暗殺された日は何年ですか。西暦の数字のみで答えて';

  final geminiModel = GeminiModel();

  final mockRag = MockLlmCommand();
  when(mockRag.execute(any)).thenAnswer((_) => info);

  test('情報の抽出', () async {
    final target = AdditionalInformationNode(geminiModel, mockRag);
    final response = await target.execute(question);
    expect(response.trim(), '1867');
  });

  test('ござる口調で回答', () async {
    final rag = AdditionalInformationNode(geminiModel, mockRag);
    final ragResult = await rag.execute('坂本龍馬が作った会社の名前はなんですか');
    expect(ragResult.contains('亀山社中'), true);
    expect(ragResult.contains('海援隊'), true);
    expect(ragResult.contains('ござる'), false);

    final talk = LlmCommand(geminiModel, samuraiTalk);
    final result = await talk.execute(ragResult);

    expect(result.contains('亀山社中'), true);
    expect(result.contains('海援隊'), true);
    expect(result.contains('ござる'), true);
  });

  test('ござる口調で回答 SequentialLlmCommand', () async {
    final sequential = SequentialLlmCommand(
      AdditionalInformationNode(geminiModel, mockRag),
      LlmCommand(geminiModel, samuraiTalk),
    );

    final result = await sequential.execute('坂本龍馬が作った会社の名前はなんですか');

    expect(result.contains('亀山社中'), true);
    expect(result.contains('海援隊'), true);
    expect(result.contains('ござる'), true);
  });

  test('お嬢様口調で回答', () async {
    final sequential = SequentialLlmCommand(
      AdditionalInformationNode(geminiModel, mockRag),
      LlmCommand(geminiModel, ojoTalk),
    );

    final result = await sequential.execute('坂本龍馬が作った会社の名前はなんですか');

    expect(result.contains('亀山社中'), true);
    expect(result.contains('海援隊'), true);
    expect(result.contains('したわ') || result.contains('ですわ'), true);
  });
}
