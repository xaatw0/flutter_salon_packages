import 'package:ollama_talk_server/src/domain/commands/command.dart';
import 'package:ollama_talk_server/src/domain/commands/llm_command.dart';
import 'package:ollama_talk_server/src/domain/commands/llm_models/gemini_model.dart';
import 'package:ollama_talk_server/src/domain/commands/nodes/router_node.dart';
import 'package:test/test.dart';

void main() {
  test('分岐', () async {
    final aboutItem = LlmCommand(GeminiModel(), 'about item');
    final aboutPrice = LlmCommand(GeminiModel(), 'about price');

    final routers = <String, ICommand>{
      '商品情報': aboutItem,
      '価格': aboutPrice,
    };
    final otherCase = LlmCommand(GeminiModel(), 'other case');

    final target = RouterNode(GeminiModel(), 'トピックを選んで', routers, otherCase);

    final result1 = await target.execute('商品Aについて教えて');
    expect(result1, aboutItem);

    final result2 = await target.execute('商品Aの価格はいくらですか');
    expect(result2, aboutPrice);

    final result3 = await target.execute('店舗はどこですか');
    expect(result3, otherCase);
  });
}
