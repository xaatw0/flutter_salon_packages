import 'dart:convert';
import 'dart:io';

import 'package:ollama_talk_common/ollama_talk_common.dart';
import 'package:ollama_talk_server/ollama_talk_server.dart';
import 'package:ollama_talk_server/src/domain/commands/check_document.dart';
import 'package:ollama_talk_server/src/domain/commands/convert_html_to_markdown.dart';
import 'package:ollama_talk_server/src/domain/commands/extract_llm_summary_from_llm_answer.dart';
import 'package:ollama_talk_server/src/domain/commands/get_wikipedia_command.dart';
import 'package:ollama_talk_server/src/domain/commands/insert_messages_into_rag_command.dart';
import 'package:ollama_talk_server/src/domain/commands/insert_messages_into_rag_with_newline_summary.dart';
import 'package:ollama_talk_server/src/domain/commands/insert_oritinal_messages_into_rag_command.dart';
import 'package:ollama_talk_server/src/domain/commands/llm_command.dart';
import 'package:ollama_talk_server/src/domain/commands/nodes/scoring_node.dart';
import 'package:ollama_talk_server/src/infrastructures/ollama/ollama_embedding_model.dart';
import 'package:ollama_talk_server/src/domain/commands/nodes/sequential_node.dart';
import 'package:ollama_talk_server/src/domain/commands/register_document.dart';
import 'package:ollama_talk_server/src/domain/commands/select_messages_from_rag_command.dart';
import 'package:ollama_talk_server/src/domain/commands/split_data_by_mark.dart';
import 'package:ollama_talk_server/src/domain/commands/trim_edit_in_markdown.dart';
import 'package:ollama_talk_server/src/domain/commands/trim_link_in_markdown.dart';
import 'package:ollama_talk_server/src/domain/commands/trim_wikipedia_command.dart';
import 'package:ollama_talk_server/src/infrastructures/ollama/ollama_llm_command.dart';
import 'package:ollama_talk_server/src/infrastructures/ollama/ollama_llm_model.dart';
import 'package:ollama_talk_server/src/infrastructures/ollama/ollama_server.dart';
import 'package:http/http.dart' as http;

void main(List<String> args) async {
  final question = args[0];

  final httpClient = http.Client();
  final file = File('bakumatu_bot_wiki.txt');
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
    TrimEditInMarkdown(),
  );

  final checkRag = CheckDocument(store: store);
  final registerRag = RegisterDocument(store: store);
  final address = OllamaAddress.create();
  final ollamaServer = OllamaServer(httpClient, address);
  final llmCommand =
      OllamaLlmCommand(ollamaServer, OllamaLlmModel.kDeepSeekR1Jp14b);
  final insertMessageIntoRag =
      InsertMessagesIntoRagCommand(embeddingModel, store: store);
  final insertOriginalMessageIntoRag =
      InsertOriginalMessagesIntoRagCommand(embeddingModel, store: store);
  final bottomPartOfPrompt = '''

以下のJSONフォーマットを参考にして、上記の内容をcontentsの項目で箇条書きで要約して。人名や出来事の名前をすべて入れて、主語や年がなければ補足して。代名詞は具体的な名称に変更して。項目内で文章が成立するようにして
```json
{
  "title": "坂本龍馬 勝海舟と神戸海軍操練所",
  "contents": [
   "文久2年（1862年）8月、坂本龍馬は江戸に到着し、小千葉道場に寄宿",
   "長崎で坂本龍馬は横井小楠を訪ね、横井小楠が勝海舟に『海軍問答』を贈る",
   "慶応元年（1865年）3月12日、神戸海軍操練所が廃止される"
  ]
}
```
''';
  final askLlmForSummary = LlmCommand(
    llmCommand,
    bottomPartOfPrompt,
    promptIn: BasePromptIn.Bottom,
  );

  final regMark1 = RegExp(r'(?<!#)(?=## )');
  final regMark2 = RegExp('(?=### )');
  final splitDataByMark = SplitDataByMark(regMark1, regMark2);
  final extractLlmSummaryFromLlmAnswer = ExtractLlmSummaryFromLlmAnswer();
  await for (final personName in fileStream) {
    final isAlreadyRegistered = await checkRag.execute(personName);
    if (isAlreadyRegistered) {
      continue;
    }

    print('processing for $personName');

    final wikiPage = await getWiki.execute(personName);

    await for (final sentence in splitDataByMark.execute(wikiPage)) {
      final stopwatch = Stopwatch()..start();

      print(
          'start: ${sentence.substring(0, sentence.length < 30 ? null : 30).replaceAll('\n', '')}');
      final llmResponse =
          await askLlmForSummary.execute('$personName $sentence');
      print('実行時間:${stopwatch.elapsed.inSeconds}秒');
      stopwatch.stop();

      final summaryFromLlm =
          extractLlmSummaryFromLlmAnswer.execute(llmResponse);
      if (summaryFromLlm != null) {
        final messages = summaryFromLlm.contents
            .map((content) => '${summaryFromLlm.title} $content');
        //await insertMessageIntoRag.execute(messages.toList());
        await insertOriginalMessageIntoRag
            .execute((sentence, messages.toList()));
      } else {
        print('- Not inserted part: $sentence');
      }
    }
    registerRag.execute(personName);
  }

  print('finish');

  // 出力データを作成する
  final selectInformationFromRag =
      SelectMessagesFromRagCommand(embeddingModel, store: store, count: 10);
  final informationFromRag = await selectInformationFromRag.execute(question);

  final distinctList = informationFromRag.toSet().toList();
  final scoring = ScoringNode(
    LlmCommand(
      OllamaLlmCommand(ollamaServer, OllamaLlmModel.kElyzaJp8b),
      '「$question」\n上記の内容に以下の内容がどれくらい関係するか10点満点で評価して。1-10の数値だけ出力',
    ),
  );
/*
  final scores = await scoring.execute(distinctList);
  for (int i = 0; i < scores.length; i++) {
    print('score: ${scores[i]} \n  ${distinctList[i]}\n\n');
  }

  final indexes = scores
      .asMap()
      .entries
      .where((entry) => 5 < (entry.value ?? 0))
      .map((entry) => entry.key)
      .toList();

        final selectedData =
      indexes.map((index) => distinctList[index]).toList();
*/
  final selectedData =
      distinctList; // indexes.map((index) => distinctList[index]).toList();

  print('資料-----\n${selectedData.join('\n----\n')}');

  // 口調
  final talkBySamurai = '上記の文章を、ござる調にして (例：です → でござる、しました → したでござる) ';

  final talkByOjo = '''お嬢様口調にして
  です → ですわ
  しました → したのよ 
      ''';

  final answerSequence = SequentialNode(
    LlmCommand(
      llmCommand,
      '${selectedData.join('\n------\n')}\n\n上記の資料から,下記の質問に対して、50文字程度で回答して。資料にない場合、「わかりません」と回答して',
      promptIn: BasePromptIn.Upper,
    ),
    LlmCommand(
      llmCommand,
      talkBySamurai,
    ),
  );

  final result = await answerSequence.execute(question);
  print('回答------\n$result');
}
