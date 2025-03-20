import 'package:ollama_talk_server/src/domain/commands/extract_llm_summary_from_llm_answer.dart';
import 'package:test/test.dart';

void main() async {
  final target = ExtractLlmSummaryFromLlmAnswer();
  final testData = '''
<think>JSONの出力</think>
```json
{
  "title": "坂本龍馬 暗殺事件の経緯と関連出来事",
  "contents": [
    "慶応3年10月24日（1867年11月25日）、山内容堂より越前福井藩へ出向した後藤象二郎は松平春嶽の上京を促し、三岡八郎と会談",
    "明治3年（1870年）、見廻組の今井信郎が佐々木只三郎ら6人による犯行を供述",
    "複数の説が存在：新選組関与説・薩摩藩黒幕説・後藤象二郎プロモーター説・フリーメイソン説"
  ]
}
```
なんか色々と出力される
      ''';
  group('extractJsonPart', () {
    test('単純', () {
      final text = '''
      ```json
      abc
      ```
      ''';
      expect(target.extractJsonPart(text).trim(), 'abc');
    });

    test('JSON見つからず', () {
      expect(target.extractJsonPart(''), '');
    });

    test('実践データ', () {
      final result = target.extractJsonPart(testData).trim();
      expect(result.startsWith('{'), true);
      expect(result.endsWith('}'), true);
      expect(result.contains('"title":'), true);
      expect(result.contains('"contents":'), true);
      expect(result.contains('"content":'), false);
    });
  });

  group('execute', () {
    test('実践データ', () {
      final result = target.execute(testData);
      expect(result, isNotNull);
      expect(result!.title, '坂本龍馬 暗殺事件の経緯と関連出来事');
      expect(result.contents.length, 3);
      expect(result.contents[0],
          '慶応3年10月24日（1867年11月25日）、山内容堂より越前福井藩へ出向した後藤象二郎は松平春嶽の上京を促し、三岡八郎と会談');
      expect(result.contents[1], '明治3年（1870年）、見廻組の今井信郎が佐々木只三郎ら6人による犯行を供述');
      expect(result.contents[2], '複数の説が存在：新選組関与説・薩摩藩黒幕説・後藤象二郎プロモーター説・フリーメイソン説');
    });
  });
}
