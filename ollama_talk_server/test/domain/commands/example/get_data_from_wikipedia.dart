import 'dart:io';

import 'package:ollama_talk_common/ollama_talk_common.dart';
import 'package:ollama_talk_server/src/domain/agents/llm_agent.dart';
import 'package:ollama_talk_server/src/domain/commands/get_web_page_command.dart';
import 'package:ollama_talk_server/src/domain/commands/llm_command.dart';
import 'package:ollama_talk_server/src/domain/commands/llm_models/gemini_model.dart';
import 'package:ollama_talk_server/src/domain/commands/write_file_command.dart';
import 'package:test/test.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart' as path;

import 'package:html2md/html2md.dart' as html2md;

void main() {
  final directory =
      Directory.systemTemp.createTempSync('get_data_from_wikipedia');

  setUpAll(() {
    directory.createTempSync();
  });
  tearDownAll(() {
    expect(directory.existsSync(), true);
    directory.deleteSync(recursive: true);
    expect(directory.existsSync(), false);
  });
  group('坂本龍馬のページを取得', () {});
  test('坂本龍馬のページを取得', () async {
    final httpClient = http.Client();
    final getWebPage = GetWebPageCommand(
        httpClient: httpClient, baseUrl: 'https://ja.wikipedia.org/wiki/');

    final llmAgent = LlmCommand(GeminiModel(),
        'HTMLをテキスト文にしてください。段落などで「##」「###」を使用して読みやすい形式にしてください。省略しないでください');

    final person = '坂本龍馬';
    final htmlData = await getWebPage.execute(person);

    final markdownData = html2md.convert(htmlData);

    //final textData = await llmAgent.execute(htmlData);

    final fileName = '$person.txt';
    final writer = WriteFileCommand(directory);
    await writer.execute(FileEntity.file(fileName, markdownData));

    expect(File(path.join(directory.path, fileName)).existsSync(), true);
  }, timeout: Timeout(Duration(minutes: 1)));
}
