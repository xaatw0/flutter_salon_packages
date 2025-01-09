import 'dart:convert';
import 'dart:io';

import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:ollama_talk_common/ollama_talk_common.dart';
import 'package:ollama_talk_server/ollama_talk_server.dart';
import 'package:ollama_talk_server/src/domain/agents/file_input_agent.dart';
import 'package:ollama_talk_server/src/domain/agents/file_output_agent.dart';
import 'package:ollama_talk_server/src/domain/agents/llm_agent.dart';
import 'package:ollama_talk_server/src/domain/agents/rag_insert_agent.dart';
import 'package:ollama_talk_server/src/domain/agents/rag_select_agent.dart';
import 'package:ollama_talk_server/src/domain/service_locator.dart';
import 'package:ollama_talk_server/src/infrastructures/ollama/ollama_server.dart';
import 'package:http/http.dart' as http;
import 'package:test/test.dart';

import 'agent_test.mocks.dart';

@GenerateNiceMocks([
  MockSpec<ServiceLocator>(),
  MockSpec<TalkServer>(),
])
void main() async {
  final ollamaServer = OllamaServer(
    http.Client(),
    OllamaAddress.create(),
  );

  final serviceLocator = MockServiceLocator();
  final talkServer = MockTalkServer();
  when(serviceLocator.ollamaTalkServer).thenReturn(talkServer);
  when(talkServer.ollamaServer).thenReturn(ollamaServer);

  ServiceLocator.setMock(serviceLocator);

  test('tags', () async {
    final result = await ollamaServer.tags();
    expect(result.length, isNot(0));
  });

  test('chat with stream', () async {
    final model = 'elyza:jp8b';

    final message1 =
        ChatRequestMessage.fromData(MessageEntity(Role.user, '坂本龍馬はだれですか'));
    final response1 =
        ollamaServer.chat(ChatRequestData(model: model, messages: [message1]));

    final sb = StringBuffer();
    await for (final message in response1) {
      sb.write(message);
    }
    expect(sb.toString().length, isNot(0));
  });

  group('chat with future', () {
    final model = 'elyza:jp8b';
    var message = '坂本龍馬はだれですか。３０文字前後。';
    test('ベース', () async {
      final message1 =
          ChatRequestMessage.fromData(MessageEntity(Role.user, message));
      final response1 = await ollamaServer.chatWithoutStream(
          ChatRequestData(model: model, messages: [message1]));
      message = response1.message?.content ?? 'No message';
      print('---- response1 ---');
      print(message);
    });
    test('変換', () async {
      final command = '''ござる調にして
  です → でござる
  しました → したでござる 
      ''';
      final command2 = '''お嬢様口調にして
  です → ですわ
  しました → したのよ 
      ''';
      final message2 = ChatRequestMessage.fromData(MessageEntity(Role.user, '''
指示：$command2
対象の文章: $message'''));

      final response2 = await ollamaServer.chatWithoutStream(
          ChatRequestData(model: model, messages: [message2]));
      message = response2.message?.content ?? 'No message';
      print('---- response2 ---');
      print(message);
    });
    test('json', () async {
      final message3 = ChatRequestMessage.fromData(MessageEntity(Role.user, '''
命令：
 - フォーマットに基づき、Json形式に変換。
 - Jsonのみ出力。フォーマットを遵守。最初と最後にJSONの始まりと終わりの括弧をつける
 - 改行コードは「\\n」
 - フォーマット: 
 {
 　"name":"%人名%",
 　"explain":"%message%"
 }
   - %人名%は対象の人名に変換。人名のみ出力
   - %message%はそのまま出力する。内容は以下の通り:
$message
'''));

      final response3 = await ollamaServer.chatWithoutStream(
          ChatRequestData(model: model, messages: [message3]));

      print('---- response3 ---');
      print(response3.message?.content ?? 'No message');
    });
  });

  group('chat with agent', () {
    final model = LlmModel('elyza:jp8b');
    var message = '';

    test('ベース', () async {
      final agent = LlmAgent(model, '[input]の内容を100文字で説明して。[inputとは]から文章を開始する');
      final response = await agent.input('坂本龍馬');
      message = response.message;
      print('---- response(ベース) ---');
      print(message);
    });

    test('変換', () async {
      final command = '''
ござる調にして
  です → でござる
  しました → したでござる 
      ''';

      final agent = LlmAgent(model, '"input"の内容を$command');
      final response = await agent.input(message);
      message = response.message;
      print('---- response(口調変換) ---');
      print(message);
    });

    test('json', () async {
      final command = '''
命令：
 - フォーマットに基づき、Json形式に変換。
 - Jsonのみ出力。フォーマットを遵守。最初と最後にJSONの始まりと終わりの括弧をつける
 - inputの内容を基本そのまま出力するが、内容がJSON形式の場合、下記のフォーマットに変換する
 - 改行コードは「\\n」。
 - フォーマット: 
 {
 　"name":"(解説対象を出力)",
 　"explain":"(inputの内容をそのまま出力)"
 }
''';

      final agent = LlmAgent(model, command);
      final response = await agent.input(message);
      message = response.message;
      print('---- response(JSONに変換) ---');
      print(message);
    });
  });

  group('Agentの連続', () {
    final serviceLocator = MockServiceLocator();
    final talkServer = MockTalkServer();
    when(serviceLocator.ollamaTalkServer).thenReturn(talkServer);
    when(talkServer.ollamaServer).thenReturn(ollamaServer);

    ServiceLocator.setMock(serviceLocator);

    final model = LlmModel('elyza:jp8b');
    test('実行', () async {
      final _formatJson = '返信のフォーマット: {"name":"[説明対象]","result","[LLMの結果]"}';

      final agentExplain = LlmAgent(model,
          '項目nameはinputをそのまま設定する。項目resultは、説明対象の100文字で説明にして。$_formatJson');

      final agentVoiceTone = LlmAgent(
        model,
        '項目inputの項目resultを「ござる」調にして $_formatJson 例）です → でござる しました → したでござる',
      );

      final agentJsonConverter = LlmAgent(model, '''
 - 項目inputの項目resultの内容を下記のフォーマットを厳守して調整する。二重のJSONにしない $_formatJson 
 - 改行コードは「\\n」
 ''');

      final agents = agentExplain
        ..setNext(agentVoiceTone)
        ..setNext(agentJsonConverter);

      final response = await agents.input('坂本龍馬');
      print('最終出力: ${response.message}');
    });
  });

  group('RAGデータ作成のテスト', () {
    final serviceLocator = MockServiceLocator();
    final talkServer = MockTalkServer();
    when(serviceLocator.ollamaTalkServer).thenReturn(talkServer);
    when(talkServer.ollamaServer).thenReturn(ollamaServer);

    ServiceLocator.setMock(serviceLocator);

    final model = LlmModel('elyza:jp8b');

    final data = '''超万能調味料塩麹
【材料】
乾燥米麹・・・・・170g
塩・・・・・・・・60g
水・・・・・・・・230cc
【作り方】
1.米麹と塩を混ぜる
2.水も加えてしっかり混ぜる
3.60℃で8時間加熱すれば完成
      ''';
    final _formatJson =
        '返信のフォーマット: {"dishName":"(料理名)","ingredients":["(材料1の名前)":"(材料1の分量)","(材料2の名前)":"(材料2の分量)",(以下すべての材料を列挙)]],"process":["(料理方法のステップ1)","(料理方法のステップ2)",(以下料理方法の全ステップ)]}';

    test('JSONファイル作成', () async {
      final agentExplain = LlmAgent(
        model,
        'inputから、料理名、材料、料理方法(調理方法のみ抽出)をフォーマットにして。JSON形式を守って。$_formatJson',
      );

      final agents = agentExplain;

      final response = await agents.input(data);
      print('最終出力: ${response.message}');
    });
  });

  group('rag agent', () {
    final file = File('test/rag_agent_test.json');
    final llmModel = LlmModel('elyza:jp8b');

    final httpClient = http.Client();

    final ollamaServer = OllamaServer(
      httpClient,
      OllamaAddress.create(),
    );

    final Store store =
        Store(getObjectBoxModel(), directory: 'object-box-rag-test');

    final serviceLocator = MockServiceLocator();
    final talkServer = TalkServer(httpClient, store, ollamaServer);
    when(serviceLocator.ollamaTalkServer).thenReturn(talkServer);

    ServiceLocator.setMock(serviceLocator);

    test('ファイルの存在', () {
      expect(file.existsSync(), true);
    });

    test('データ登録と取得', () async {
      store.box<DocumentBox>().removeAll();
      store.box<DocumentEmbeddingBox>().removeAll();

      final message = '坂本龍馬は、幕末の日本を代表する志士です。土佐藩出身で、薩摩藩と長州藩を結び、倒幕運動に尽力しました';
      final agentInsert = RagInsertAgent(llmModel);
      await agentInsert.process(message);

      final agentSelect = RagSelectAgent();
      final result = await agentSelect.process('坂本龍馬');
      final jsonData = jsonDecode(result.message);
      expect(jsonData['data'].length, 1);
      expect(jsonData['data'][0], message);
    });

    test('複数データ', () async {
      store.box<DocumentBox>().removeAll();
      store.box<DocumentEmbeddingBox>().removeAll();

      final list = jsonDecode(file.readAsStringSync()) as List<dynamic>;
      expect(list.length, 7);

      final agentInsert = RagInsertAgent(llmModel);
      for (var i = 0; i < list.length; i++) {
        await agentInsert.process(list[i].toString());
      }

      final agentSelect = RagSelectAgent();
      for (final prompt in ['醤油', 'しょうゆ', '低温調理', '牛もも肉']) {
        final result = await agentSelect.process(prompt);
        final jsonData = jsonDecode(result.message)['data'] as List<dynamic>;

        expect(jsonData[0] is String, true);
        expect(jsonData[0] is Map, false);
        expect(jsonData[0] is Map<String, dynamic>, false);

        print('\n$prompt:');
        for (int i = 0; i < jsonData.length; i++) {
          final dishName = jsonData[i].toString().split(',')[0].split(':')[1];
          print(dishName);
        }
      }
    });
  });

  group('file agent', () {
    final llmModel = LlmModel('elyza:jp8b');
    final httpClient = http.Client();

    final ollamaServer = OllamaServer(
      httpClient,
      OllamaAddress.create(),
    );
    final mockTalkServer = MockTalkServer();
    when(mockTalkServer.ollamaServer).thenReturn(ollamaServer);
    ServiceLocator.setMock(serviceLocator);

    test('file output', () async {
      final message = '''
The output files are as follows
- test/agent_test1.txt
test1
- test/agent_test2.txt
test2''';

      final fileOutputAgent = FileOutputAgent(llmModel);
      final response = await fileOutputAgent.input(message);
      await Future.delayed(const Duration(milliseconds: 5));
      final fileNames = jsonDecode(response.message) as List<dynamic>;
      expect(fileNames[0], 'test/agent_test1.txt');
      expect(fileNames[1], 'test/agent_test2.txt');

      expect(File(fileNames[0]).readAsStringSync().trim(), 'test1');
      expect(File(fileNames[1]).readAsStringSync().trim(), 'test2');

      final fileInputAgent = FileInputAgent();
      final responseFiles = await fileInputAgent.process(
          'test/agent_test1.txt, test/agent_test2.txt, test/agent_test3.txt');
      final fileDataList = jsonDecode(responseFiles.message) as List<dynamic>;
      expect(fileDataList.length, 3);

      final resultFiles = [
        'test/agent_test1.txt',
        'test/agent_test2.txt',
        'test/agent_test3.txt',
      ];

      final resultContent = ['test1', 'test2', ''];
      final resultError = ['', '', 'not found'];

      for (int i = 0; i < fileDataList.length; i++) {
        final entity = FileEntity.fromJson(fileDataList[i]);
        expect(entity.fileName, resultFiles[i]);
        expect(entity.content, resultContent[i]);
        expect(entity.errorMessage ?? '', resultError[i]);
      }

      fileNames.forEach((fileName) => File(fileName).deleteSync());
      fileNames.forEach(
        (fileName) => expect(File(fileName).existsSync(), false),
      );
    });
  });
}
