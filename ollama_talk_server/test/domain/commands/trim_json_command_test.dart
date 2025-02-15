import 'package:ollama_talk_server/src/domain/commands/trim_json_command.dart';
import 'package:test/test.dart';

void main() {
  final target = TrimJsonCommand();
  test('該当あり', () {
    final data1 = '```json\n{"test":"test"}\n```';
    expect(target.execute(data1), '{"test":"test"}');

    final data2 = '```json\n{"test":"test"}```';
    expect(target.execute(data2), '{"test":"test"}');
  });
  test('該当なし', () async {
    final data1 = '\n{"test":"test"}\n';
    expect((await target.execute(data1)).trim(), '{"test":"test"}');

    final data2 = '{"test":"test"}';
    expect((await target.execute(data2)).trim(), '{"test":"test"}');
  });
}
