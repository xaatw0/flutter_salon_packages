import 'package:ollama_talk_common/ollama_talk_common.dart';
import 'package:ollama_talk_server/src/infrastructures/ollama/ollama_llm_command.dart';
import 'package:ollama_talk_server/src/infrastructures/ollama/ollama_llm_model.dart';
import 'package:ollama_talk_server/src/infrastructures/ollama/ollama_server.dart';
import 'package:http/http.dart' as http;

void main() async {
  final ragInfo = '''
## 坂本龍馬   概略
土佐藩郷士の家に生まれ、脱藩した後は志士として活動し、貿易会社と政治組織を兼ねた亀山社中（のちの海援隊）を結成した。薩長同盟の成立に協力するなど、倒幕および明治維新に関与した。大政奉還成立後の慶応3年11月15日（1867年12月10日）に京都河原町通蛸薬師下ルの近江屋において暗殺された。実行犯については今井信郎による自供から、京都見廻組によるものという説が有力であるが[2]、異説もある（詳細は「近江屋事件」を参照）。贈正四位。
## 西郷 隆盛（さいごう たかもり、旧字体：西鄕 隆󠄁盛󠄁、1828年1月23日（文政10年12月7日）- 1877年（明治10年）9月24日）は、幕末から明治初期の日本の政治家、軍人[1]。
薩摩国薩摩藩の下級藩士・西郷吉兵衛隆盛の長男。諱は元服時に隆永（たかなが）のちに武雄・隆盛（たかもり）と名を改めた。幼名は小吉、通称は吉之介、善兵衛、吉兵衛、吉之助と順次変更。号は南洲（なんしゅう）。西郷隆盛は父と同名であるが、これは王政復古の章典で位階を授けられる際に親友の吉井友実が誤って父・吉兵衛の名で届け出てしまい、それ以後は父の名を名乗ったためである。一時、西郷三助・菊池源吾・大島三右衛門・大島吉之助などの変名も名乗った。
上記の資料に基づいて、以下の質問に答えてください
  ''';

  final prompts = [
    'LLMのモデルを数個テストするのによいプロンクトを10個列挙して。',
    '第二次世界大戦の主な原因と影響を、簡潔かつ包括的に説明してください。',
    '空のファンタジー小説の冒頭200文字を書いてください。設定は『古代文明が栄えた世界で、天空都市が墜落する前夜』。',
    'Dartでシングルトンパターンを実装してください。また、そのコードの各部分の説明を加えてください。',
    '次の数列の一般項を求めてください: 2, 5, 10, 17, 26, …',
    '西部劇の酒場にいる無口なガンマンとおしゃべりなバーテンダーが会話をする場面を、ユーモアを交えて書いてください。',
    'FlutterのPageStorageとは何ですか？その使い方とメリットを具体的なコード例とともに説明してください。',
    'AIが人間社会に貢献するために、どのような倫理的ガイドラインが必要か、5つのポイントで説明してください。',
    '''
    Aさん、Bさん、Cさんのうち、1人が嘘つきで他の2人は真実を話します。以下の証言から、嘘つきを特定してください。
A:『Bは嘘をついている』
B:『Cは嘘をついている』
C:『私は嘘をついていない』
    ''',
    '$ragInfo 坂本龍馬はなにをしましたか。',
    '$ragInfo 坂本龍馬はどのように死にましたか。',
    '$ragInfo 坂本龍馬はいつ死にましたか。年月日で答えて',
    '$ragInfo 西郷隆盛はいつ死にましたか。',
    '$ragInfo 西郷隆盛は何をしましたか',
    '$ragInfo 西郷隆盛にはどのような名前がありますか',
  ];

  final llmModels = [
    OllamaLlmModel.kElyzaJp8b,
    OllamaLlmModel.kRakuten20Mini15b,
    OllamaLlmModel.kDeepSeekR1Jp14b,
    OllamaLlmModel.kTanuki
  ];
  final httpClient = http.Client();
  final address = OllamaAddress.create();
  final ollamaServer = OllamaServer(httpClient, address);
  for (final prompt in prompts) {
    print('\n\n ## prompt: $prompt\n');
    for (final ollamaLlmModel in llmModels) {
      final command = OllamaLlmCommand(ollamaServer, ollamaLlmModel);
      Stopwatch stopwatch = Stopwatch();
      stopwatch.start();
      await command.execute(prompt).then((result) {
        print(
            '### ${ollamaLlmModel()} \n実行時間:${stopwatch.elapsed.inSeconds}秒\n$result\n\n');
        stopwatch.stop();
      });
    }
  }
}
