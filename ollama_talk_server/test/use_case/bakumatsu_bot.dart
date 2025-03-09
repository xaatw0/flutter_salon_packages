import 'dart:convert';
import 'dart:io';

import 'package:ollama_talk_common/ollama_talk_common.dart';
import 'package:ollama_talk_server/ollama_talk_server.dart';
import 'package:ollama_talk_server/src/domain/commands/check_document.dart';
import 'package:ollama_talk_server/src/domain/commands/convert_html_to_markdown.dart';
import 'package:ollama_talk_server/src/domain/commands/get_wikipedia_command.dart';
import 'package:ollama_talk_server/src/domain/commands/insert_messages_into_rag_command.dart';
import 'package:ollama_talk_server/src/domain/commands/insert_messages_into_rag_with_newline_summary.dart';
import 'package:ollama_talk_server/src/domain/commands/llm_command.dart';
import 'package:ollama_talk_server/src/domain/commands/llm_models/ollama_embedding_model.dart';
import 'package:ollama_talk_server/src/domain/commands/llm_models/ollama_model.dart';
import 'package:ollama_talk_server/src/domain/commands/nodes/additional_information_node.dart';
import 'package:ollama_talk_server/src/domain/commands/nodes/sequential_node.dart';
import 'package:ollama_talk_server/src/domain/commands/register_document.dart';
import 'package:ollama_talk_server/src/domain/commands/select_messages_from_rag_command.dart';
import 'package:ollama_talk_server/src/domain/commands/split_data_by_mark.dart';
import 'package:ollama_talk_server/src/domain/commands/trim_link_in_markdown.dart';
import 'package:ollama_talk_server/src/domain/commands/trim_wikipedia_command.dart';
import 'package:ollama_talk_server/src/infrastructures/ollama/ollama_server.dart';
import 'package:http/http.dart' as http;

void main(List<String> args) async {
  final paddingLength = 128;
  final partLength = 512;

  final question = args[0];

  final httpClient = http.Client();
  final file = File('bakumatu_bot_wiki_test.txt');
  final store = await openStore(directory: 'bakumatsu-db');
  final embeddingModel =
      OllamaEmbeddingModel(EmbeddingModel.kclNagoyaRuriLarge);

  Stream<String> fileStream = file
      .openRead()
      .transform(utf8.decoder) // バイトを文字列に変換
      .transform(const LineSplitter()); // 行に分割

  final getWiki = SequentialNode(
    GetWikipediaCommand(httpClient),
    TrimWikipediaCommand(),
    ConvertHtmlToMarkdown(),
    TrimLinkInMarkdown(),
  );

  final checkRag = CheckDocument(store: store);
  final registerRag = RegisterDocument(store: store);
  final address = OllamaAddress.create();
  final ollamaServer = OllamaServer(httpClient, address);
  final llmModel = OllamaModel(ollamaServer);

  await for (final name in fileStream) {
    final isAlreadyRegistered = await checkRag.execute(name);
    if (isAlreadyRegistered) {
      continue;
    }

    print('processing for $name');

    final wikiPage = await getWiki.execute(name);

    final askLlmForSummary = LlmCommand(
      OllamaModel(ollamaServer),
      '「対象文章」をRAGで検索できるように要約して。「例」を参考に羅列して(羅列部分のみを出力) \n\n例：\n・坂本龍馬の誕生\n・西郷隆盛の幼少・青年時代\n\nこれより下が、「対象文章」です',
    );

    final insertMessagesIntoRagWithNewlineSummary =
        InsertMessagesIntoRagWithNewlineSummary(
      embeddingModel,
      llmCommandForSummary: askLlmForSummary,
      store: store,
    );

    final insertMessageIntoRag =
        InsertMessagesIntoRagCommand(embeddingModel, store: store);

    List<String> splitByLength(String message, int length) =>
        RegExp('.{1,$length}')
            .allMatches(message)
            .map((m) => m.group(0)!)
            .toList();

    final regMark1 = RegExp(r'(?<!#)(?=## )');
    final regMark2 = RegExp('(?=### )');

    final splitData = SplitDataByMark(regMark1, regMark2);
    final stream = splitData.execute(wikiPage);
    await for (final message in stream) {
      final isLong = 150 < message.length;
      final startPart = '$nameについて' + (isLong ? message.substring(0, 20) : '');
      final chunks = isLong
          ? splitByLength(message.substring(20).replaceAll('\n', ''), 256)
              .map((e) => '$startPart $e')
              .toList()
          : [message];

      assert(chunks.every((e) => e.length < 300));
      await insertMessageIntoRag.execute(chunks);
    }

    /*
    for (int index = 0;
        index < wikiPage.length;
        index += (partLength - paddingLength)) {
      final endAt =
          index + partLength < wikiPage.length ? index + partLength : null;
      final data = wikiPage.substring(index, endAt);

      await insertMessageIntoRag.execute([data]);

      print('$endAt/${wikiPage.length}');
    }


// 要約して、RAGにいれる
    for (int index = 0;
        index < wikiPage.length;
        index += (partLength - paddingLength)) {
      final endAt =
          index + partLength < wikiPage.length ? index + partLength : null;
      final data = wikiPage.substring(index, endAt);

      await insertMessagesIntoRagWithNewlineSummary.execute(data);
      print('$endAt/${wikiPage.length}');
    }
*/
    registerRag.execute(name);
  }

  print('finish');

  // 出力データを作成する
  final selectInformationFromRag =
      SelectMessagesFromRagCommand(embeddingModel, store: store, count: 8);
  final messages = await selectInformationFromRag.execute(question);

  final data = messages.join('\n----\n');
  print('資料-----\n$data');

  // 口調
  final talkBySamurai = '''ござる調にして
  です → でござる
  しました → したでござる 
      ''';
  final talkByOjo = '''お嬢様口調にして
  です → ですわ
  しました → したのよ 
      ''';

  final answerSequence = SequentialNode(
    llmModel,
    LlmCommand(llmModel, talkBySamurai),
  );

  final result =
      await answerSequence.execute('$data \n\n $question(上記の資料から答えてください)');
  print('回答------\n$result');
}
