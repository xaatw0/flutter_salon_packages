import 'package:ollama_talk_server/src/domain/commands/get_web_page_command.dart';
import 'package:test/test.dart';
import 'package:http/http.dart' as http;

void main() {
  final httpClient = http.Client();
  group('wikipedia', () {
    final baseUrl = 'https://ja.wikipedia.org/wiki/';
    final target = GetWebPageCommand(httpClient: httpClient, baseUrl: baseUrl);

    test('坂本龍馬', () async {
      final response = await target.execute('坂本龍馬');
      expect(response.contains('千鶴'), true);
      expect(response.contains('ナポレオン'), false);
    });
  });
}
