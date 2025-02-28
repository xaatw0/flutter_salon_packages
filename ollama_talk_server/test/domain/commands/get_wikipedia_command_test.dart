import 'package:http/http.dart' as http;
import 'package:ollama_talk_server/src/domain/commands/get_wikipedia_command.dart';
import 'package:test/test.dart';

void main() {
  test('実際に取得', () async {
    final client = http.Client();
    final target = GetWikipediaCommand(client);

    final result = await target.execute('坂本龍馬');
    expect(result.contains('坂本龍馬'), true);
  });
}
