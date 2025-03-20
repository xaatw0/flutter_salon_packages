import 'package:ollama_talk_server/src/domain/commands/trim_edit_in_markdown.dart';
import 'package:test/test.dart';

main() {
  group('編集を削除', () {
    final data = r'''
    坂本龍馬について### 暗殺

\[[編集]\]

→詳 都市[河原町]
    ''';
    final reg = RegExp('\\\\\\[\\[編集]\\\\\\]');

    test('テスト', () {
      final reg = RegExp('\\\\\\[\\[編集]\\\\\\]');
      expect(reg.hasMatch(data), true);
    });

    test('編集を削除', () {
      final target = TrimEditInMarkdown();
      final result = target.execute(data);

      expect(reg.hasMatch(data), true);
      expect(reg.hasMatch(result), false);
    });
  });
}
