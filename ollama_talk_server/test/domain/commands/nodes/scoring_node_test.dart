import 'package:ollama_talk_common/ollama_talk_common.dart';
import 'package:ollama_talk_server/src/domain/commands/llm_command.dart';
import 'package:ollama_talk_server/src/domain/commands/nodes/scoring_node.dart';
import 'package:ollama_talk_server/src/infrastructures/ollama/ollama_llm_command.dart';
import 'package:ollama_talk_server/src/infrastructures/ollama/ollama_llm_model.dart';
import 'package:ollama_talk_server/src/infrastructures/ollama/ollama_server.dart';
import 'package:test/test.dart';
import 'package:http/http.dart' as http;

void main() async {
  var shortText =
      '11月15日、京都四条の[近江屋]に坂本龍馬を訪問中、何者かに襲撃され両手足など11箇所を斬られて瀕死となる（[近江屋事件]）。';

  var longText = '''
      *   [歴代徳川将軍]で唯一、将軍として[江戸城]に入らなかった人物である。すでに将軍ではなくなっていた鳥羽伏見の戦いの敗戦後に初めて江戸城に入り、その後の謹慎までの短い時間を慌ただしく過ごしただけである[\[57\]]。
*   英邁さで知られ、実父斉昭の腹心・[安島帯刀]は、慶喜を「徳川の流れを清ましめん御仁」と評し、幕威回復の期待を一身に背負い鳴物入りで将軍位に就くと、「[権現様]の再来」とまでその英明を称えられた。慶喜た。
*   [鳥羽・伏見の戦い]後の「敵前逃亡」など惰弱なイメージがあったが、大政奉還後に新たな近代的政治体制を築こうとしたことなどが近年クローズアップされ、加えて大河ドラマ『[徳川慶喜] "徳川慶喜 ")』の放送などもあり、再評価する動きもある。
*   [慶応の改革]の一環として建築された[横須賀製鉄所]は明治政府に引き継がれ、現在もその一部が[在日米軍]の[横須賀海軍施設ドック]として利用されている。また同時期に[幕府陸軍]の人員増強やフランス軍事顧問されている。慶応の改革はその後の動乱の中で頓挫したものの日本の近代化に少なからず貢献した。
*   [坂本龍馬]は大政奉還後の政権を慶喜が主導することを想定していた、と指摘する研究者もいる[\[135\]]。司馬遼太郎の作品では「大樹（将軍）公、今日の心中さこそと察し奉る。よくも断じ給へるものかな、よくも介されている。ただし、慶喜自身が龍馬の存在を知ったのは明治になってからと言われる。
      ''';
  final client = http.Client();
  final address = OllamaAddress.create();
  final ollamaServer = OllamaServer(client, address);

  group('LLM プロンクト', () {
    test('数値のフォーマットで帰ってくること', () async {
      final command = LlmCommand(
        OllamaLlmCommand(ollamaServer, OllamaLlmModel.kElyzaJp8b),
        '「坂本龍馬はどのように死にましたか」\n上記の内容に以下の内容がどれくらい関係するか10点満点で評価して。1-10の数値だけ出力',
      );

      final resultShortText = await command.execute(shortText);
      expect(int.tryParse(resultShortText), greaterThan(7));

      final resultLongText = await command.execute(longText);
      expect(int.tryParse(resultLongText), isNotNull);
    });
  });

  group('ScoringNode', () {
    test('', () async {
      final command = ScoringNode(
        LlmCommand(
          OllamaLlmCommand(ollamaServer, OllamaLlmModel.kElyzaJp8b),
          '「坂本龍馬はどのように死にましたか」\n上記の内容に以下の内容がどれくらい関係するか10点満点で評価して。1-10の数値だけ出力',
        ),
      );

      final scores = await command.execute(
        [
          shortText,
          longText,
          '長官[寺内正毅]、野戦衛生長官[石黒忠悳]、陸軍大臣[大山巌]、海軍大臣[西郷従道]、海軍軍令部長[樺山資紀]、侍従武官長・軍事内局長岡沢精（ただし彼は議席には列さず、軍議中常に天皇の御側に侍立していた）、そ具体的に作戦を提案して命じるようなことはなかったものの、戦況には強い関心を持ち、不明点は頻繁に問いただした[\[775\]]',
        ],
      );

      expect(scores.length, 3);
      expect(scores[0], greaterThan(6));
      expect(scores[1], lessThan(5));
      expect(scores[2], lessThan(5));
    });
  });
}
