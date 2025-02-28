import 'dart:io';

import 'package:ollama_talk_server/src/domain/commands/trim_wikipedia_command.dart';
import 'package:test/test.dart';

void main() {
  final testFile = File('test/domain/commands/trim_wikipedia_command_test.txt');
  test('ファイルの存在', () {
    expect(testFile.existsSync(), true);
  });

  test('実行', () async {
    final target = TrimWikipediaCommand();
    final data = testFile.readAsStringSync();
    final trimData = await target.execute(data);

    expect(data.contains('典拠管理データベース'), true);
    expect(trimData.contains('典拠管理データベース'), false);
    expect(trimData.length < data.length, true);
  });
}
