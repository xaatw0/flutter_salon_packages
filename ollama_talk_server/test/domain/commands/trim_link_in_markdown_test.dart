import 'package:ollama_talk_server/src/domain/commands/trim_link_in_markdown.dart';
import 'package:test/test.dart';

void main() async {
  test('basic', () {
    final data = '''
    | 所属 | [海援隊](/wiki/%E6%B5%B7%E6%8F%B4%E9%9A%8A "海援隊") |
    | 受賞 | [贈](/wiki/%E8%B4%88%E4%BD%8D "贈位")[正四位](/wiki/%E6%AD%A3%E5%9B%9B%E4%BD%8D "正四位") |
    ''';
    final trimData = '''
    | 所属 | [海援隊] |
    | 受賞 | [贈][正四位] |
    ''';

    final target = TrimLinkInMarkdown();
    final result = target.execute(data);
    expect(result, trimData);
  });
}
