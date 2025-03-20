import 'package:mockito/annotations.dart';
import 'package:ollama_talk_common/ollama_talk_common.dart';
import 'package:ollama_talk_server/ollama_talk_server.dart';
import 'package:ollama_talk_server/src/domain/commands/insert_messages_into_rag_command.dart';
import 'package:ollama_talk_server/src/infrastructures/ollama/ollama_embedding_model.dart';
import 'package:ollama_talk_server/src/domain/commands/select_messages_from_rag_command.dart';
import 'package:ollama_talk_server/src/domain/service_locator.dart';
import 'package:ollama_talk_server/src/infrastructures/ollama/ollama_server.dart';
import 'package:test/test.dart';
import 'package:http/http.dart' as http;

@GenerateNiceMocks([
  MockSpec<TalkServer>(),
  MockSpec<ServiceLocator>(),
])
void main() {
  test('embeddingを実際に通信してテストする', () async {
    final httpClient = http.Client();
    final address = OllamaAddress.create('localhost:11434');
    final ollamaServer = OllamaServer(httpClient, address);
    final result =
        await ollamaServer.embed(EmbeddingModel.kDefaultModel(), 'test');
    expect(result.embeddings.first.first, 0.0055496376);
  });

  Future<Store> getStore() async {
    await Future.delayed(const Duration(milliseconds: 10));
    return openStore(
        directory:
            'memory:object-box-${DateTime.now().millisecondsSinceEpoch}');
  }

  group('embeddingの動作確認', () {
    final messages = [
      "宇宙探査の未来: 人類の夢は遥か彼方の宇宙へと向かい続けている。最新の宇宙技術は、月や火星への有人探査計画を現実味あるものにし、宇宙ステーションや深宇宙探査機の進化は、新たな発見と未知の領域への扉を開いている。これにより、宇宙の謎や地球外生命体の存在といった課題に対して、国際的な協力がますます重要になっている。",
      "伝統的な日本料理: 日本料理は、季節感と繊細な味わいを大切にする伝統文化のひとつである。旬の食材を活かし、見た目にも美しい盛り付けや丁寧な調理法が特徴で、寿司、天ぷら、和菓子など多様なメニューが国内外で愛されている。この奥深い味わいは、世代を超えて受け継がれ、現代の食文化にも多大な影響を与えている。",
      "環境保護とサステイナビリティ: 地球規模での環境問題が深刻化する中、環境保護とサステイナビリティは私たちの未来を左右する重要なテーマとなっている。再生可能エネルギーの普及や資源の循環利用、エコロジカルなライフスタイルの推進など、持続可能な社会を実現するための取り組みが世界各地で行われている。個人と社会全体が協力し、より良い未来を築くための意識改革が求められている。",
      "最新テクノロジーと人工知能: 現代社会は、急速に発展するテクノロジーによって大きく変貌を遂げている。特に人工知能（AI）の進化は、医療、金融、交通などあらゆる分野で革新的な変化をもたらし、データ解析や自動運転、ロボット工学の発展に寄与している。一方で、倫理的な課題やプライバシー保護の問題も浮上しており、技術革新と共に解決策を模索することが急務である。",
      "世界の歴史的遺産と文化: 世界各地には、古代文明の遺跡から中世の城郭、近代の建築物まで、豊かな歴史と文化が息づく数多くの遺産が存在する。これらの文化財は、その地域の歴史や伝統を物語る貴重な証拠であり、観光資源としても大きな価値を持つ。また、国際社会による保護活動が進む中、これらの遺産は未来への知識の継承や文化交流の架け橋として重要な役割を果たしている。",
    ];

    test('データの出し入れ', () async {
      final embeddingModel = OllamaEmbeddingModel(EmbeddingModel.kDefaultModel);
      final embeddingDataForInsert = await embeddingModel.execute(messages);
      expect(embeddingDataForInsert.length, 5);

      final store = await getStore();

      final insertMessage =
          InsertMessagesIntoRagCommand(embeddingModel, store: store);
      final future = insertMessage.execute(messages);

      await future;

      final selectMessage =
          SelectMessagesFromRagCommand(embeddingModel, store: store, count: 3);
      final japaneseFoodText = selectMessage.execute('伝統的な日本料理');

      expect((await japaneseFoodText).length, 3);
      expect((await japaneseFoodText).first.startsWith('伝統的な日本料理'), true);
      expect((await japaneseFoodText).first.startsWith('宇宙探査の未来'), false);

      final castleText = selectMessage.execute('城');
      expect((await castleText).first.startsWith('世界の歴史的遺産と文化'), true);
      expect((await castleText).first.startsWith('宇宙探査の未来'), false);

      final androidText = selectMessage.execute('アンドロイド');
      print((await androidText).join('\n'));
      expect((await androidText).first.startsWith('最新テクノロジーと人工知能'), true);
      expect((await androidText).first.startsWith('宇宙探査の未来'), false);
    });

    test('データのサイズ', () async {
      final resultMxbai =
          await OllamaEmbeddingModel(EmbeddingModel.kMxbaiEmbedLarge)
              .execute(messages);
      expect(resultMxbai.length, 5);
      expect(resultMxbai.every((e) => e.length == 1024), true);

      final resultRuri =
          await OllamaEmbeddingModel(EmbeddingModel.kclNagoyaRuriLarge)
              .execute(messages);
      expect(resultRuri.length, 5);
      expect(resultRuri.every((e) => e.length == 1024), true);
    });
  });
}
