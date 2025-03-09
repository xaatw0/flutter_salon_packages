import 'dart:convert';
import 'dart:io';

import 'package:mockito/annotations.dart';
import 'package:http/http.dart' as http;
import 'package:mockito/mockito.dart';
import 'package:ollama_talk_common/ollama_talk_common.dart';
import 'package:ollama_talk_server/ollama_talk_server.dart';
import 'package:ollama_talk_server/src/infrastructures/ollama/ollama_server.dart';
import 'package:test/test.dart';

import 'ollama_server_test.mocks.dart';

@GenerateNiceMocks([MockSpec<http.Client>()])
void main() {
  final client = MockClient();
  final target = OllamaServer(client, OllamaAddress.create());

  group('embed', () {
    test('embed 単数メッセージ', () async {
      final body = '''
    {
  "model": "all-minilm",
  "embeddings": [[
    0.010071029, -0.0017594862, 0.05007221, 0.04692972, 0.054916814,
    0.008599704, 0.105441414, -0.025878139, 0.12958129, 0.031952348
  ]],
  "total_duration": 14143917,
  "load_duration": 1019500,
  "prompt_eval_count": 8
}
    ''';

      when(
        client.post(
          Uri.parse('http://localhost:11434/api/embed'),
          body: jsonEncode(
              {"model": "all-minilm", "input": "Why is the sky blue?"}),
          headers: {'Content-Type': 'application/json'},
          encoding: null,
        ),
      ).thenAnswer((_) async => http.Response(body, HttpStatus.ok));

      final result = await target.embed('all-minilm', 'Why is the sky blue?');
      expect(result.model, 'all-minilm');
      expect(result.totalDuration, 14143917);
      expect(result.loadDuration, 1019500);
      expect(result.promptEvalCount, 8);
      expect(result.embeddings.length, 1);
      expect(result.embeddings[0].length, 10);
      expect(result.embeddings[0][0], 0.010071029);
    });

    test('embed 複数メッセージ', () async {
      final body = '''
    {
  "model": "all-minilm",
  "embeddings": [[
    0.010071029, -0.0017594862, 0.05007221, 0.04692972, 0.054916814,
    0.008599704, 0.105441414, -0.025878139, 0.12958129, 0.031952348
  ],[
    -0.0098027075, 0.06042469, 0.025257962, -0.006364387, 0.07272725,
    0.017194884, 0.09032035, -0.051705178, 0.09951512, 0.09072481
  ]]
}
    ''';

      when(
        client.post(
          Uri.parse('http://localhost:11434/api/embed'),
          body: jsonEncode(
              {"model": "all-minilm", "input": "Why is the sky blue?"}),
          headers: {'Content-Type': 'application/json'},
          encoding: null,
        ),
      ).thenAnswer((_) async => http.Response(body, HttpStatus.ok));

      final result = await target.embed('all-minilm', 'Why is the sky blue?');
      expect(result.model, 'all-minilm');
      expect(result.totalDuration, isNull);
      expect(result.loadDuration, isNull);
      expect(result.promptEvalCount, isNull);
      expect(result.embeddings.length, 2);
      expect(result.embeddings[0].length, 10);
      expect(result.embeddings[0][0], 0.010071029);
    });

    test('embedWithMultipleInput', () async {
      final body = '''
{
  "model": "all-minilm",
  "embeddings": [[
    0.010071029, -0.0017594862, 0.05007221, 0.04692972, 0.054916814,
    0.008599704, 0.105441414, -0.025878139, 0.12958129, 0.031952348
  ],[
    -0.0098027075, 0.06042469, 0.025257962, -0.006364387, 0.07272725,
    0.017194884, 0.09032035, -0.051705178, 0.09951512, 0.09072481
  ]]
}
    ''';

      when(
        client.post(
          Uri.parse('http://localhost:11434/api/embed'),
          body: jsonEncode({
            "model": "all-minilm",
            "input": ["Why is the sky blue?", "Why is the grass green?"]
          }),
          headers: {'Content-Type': 'application/json'},
          encoding: null,
        ),
      ).thenAnswer((_) async => http.Response(body, HttpStatus.ok));

      final result = await target.embedWithMultipleInput(
          'all-minilm', ["Why is the sky blue?", "Why is the grass green?"]);
      expect(result.model, 'all-minilm');
      expect(result.totalDuration, isNull);
      expect(result.loadDuration, isNull);
      expect(result.promptEvalCount, isNull);
      expect(result.embeddings.length, 2);
      expect(result.embeddings[0].length, 10);
      expect(result.embeddings[0][0], 0.010071029);
      expect(result.embeddings[1][0], -0.0098027075);
    });
  });

  group('chat', () {
    test('Streaming', () {
      // StreamedResponse を使用して、バイナリを発信しないといけないの、テスト不可と判断
    });

    test('No streaming', () async {
      final body = '''
{
  "model": "llama3.2",
  "created_at": "2023-12-12T14:13:43.416799Z",
  "message": {
    "role": "assistant",
    "content": "Hello! How are you today?"
  },
  "done": true,
  "total_duration": 5191566416,
  "load_duration": 2154458,
  "prompt_eval_count": 26,
  "prompt_eval_duration": 383809000,
  "eval_count": 298,
  "eval_duration": 4799921000
}
    ''';

      when(
        client.post(
          Uri.parse('http://localhost:11434/api/chat'),
          body: jsonEncode({
            "model": "llama3.2",
            "messages": [
              {"role": "user", "content": "why is the sky blue?"}
            ],
            "options": null,
            "stream": false
          }),
          headers: {'Content-Type': 'application/json'},
          encoding: null,
        ),
      ).thenAnswer((_) async => http.Response(body, HttpStatus.ok));

      final chatRequest = ChatRequestData(model: 'llama3.2', messages: [
        ChatRequestMessage(role: 'user', content: 'why is the sky blue?')
      ]);
      final result = await target.chatWithoutStream(chatRequest);
      expect(result.model, 'llama3.2');
      expect(result.message?.content, 'Hello! How are you today?');
      expect(result.done, true);
      expect(result.totalDuration, 5191566416);
      expect(result.loadDuration, 2154458);
      expect(result.promptEvalCount, 26);
      expect(result.promptEvalDuration, 383809000);
      expect(result.evalCount, 298);
      expect(result.evalDuration, 4799921000);
    });
  });

  group('tags', () {
    test('Llm model: 1 embed model: 1', () async {
      final body =
          ' {"models":[{"name":"mxbai-embed-large:latest","model":"mxbai-embed-large:latest","modified_at":"2024-12-29T21:28:07.815504638-08:00","size":669615493,"digest":"468836162de7f81e041c43663fedbbba921dcea9b9fefea135685a39b2d83dd8","details":{"parent_model":"","format":"gguf","family":"bert","families":["bert"],"parameter_size":"334M","quantization_level":"F16"}},{"name":"elyza:jp8b","model":"elyza:jp8b","modified_at":"2024-12-25T15:31:15.565369276-08:00","size":4920734779,"digest":"975044073ed096b0e96201d655851a84f435c857bc9226380d015511b4cbaa28","details":{"parent_model":"","format":"gguf","family":"llama","families":["llama"],"parameter_size":"8.0B","quantization_level":"Q4_K_M"}}]}';

      when(
        client.get(
          Uri.parse('http://localhost:11434/api/tags'),
          headers: {'Content-Type': 'application/json'},
        ),
      ).thenAnswer((_) async => http.Response(body, HttpStatus.ok));

      final result = await target.tags();
      expect(result.length, 2);
      expect(result[0].name, 'mxbai-embed-large:latest');
      expect(result[1].name, 'elyza:jp8b');
    });
  });

  group('embeddingは実際に動作するか', () {
    final client = http.Client();
    final target = OllamaServer(client, OllamaAddress.create());
    test('mxbai-embed-large', () async {
      final result =
          await target.embed(EmbeddingModel.kMxbaiEmbedLarge(), 'test');
      expect(result.model, EmbeddingModel.kMxbaiEmbedLarge());
      expect(result.embeddings.length, greaterThan(0));
      expect(result.embeddings.first.length, greaterThan(0));
    });

    test('kun432/cl-nagoya-ruri-large:latest', () async {
      final message =
          '"坂本龍馬について  ### 幼少年期\n\n\\[[編集]\\]\n\n[![]]\n\n[高知市]の生誕地・[北緯33度33分25.8秒 東経133度31分33.6秒]\n\n[天保]6年[11月15日] \"11月15日 \")（[1836年][1月3日]）[\\[注 2\\]]、龍馬は[土佐国]土佐郡上街本町一丁目（現・[高知県][高知市][上町] \"上町 \")一丁目）の土佐藩郷士（下級武士・[足軽]）坂本家に父・[坂本直足]（八平）、母・[幸]の間の二男として生まれた。22歳年上の兄（[権平]）と3人の姉（千鶴、栄、[乙女]）がいた。坂本家は[質屋]、酒造業、呉服商を営む[豪商]才谷屋の分家で、第六代・直益のときに長男・直海が藩から郷士御用人に召し出されて坂本家を興した[\\[3\\]]。土佐藩の武士階級には上士と下士があり、商家出身の坂本家は下士（郷士）だったが（坂本家は福岡家に仕えていたという）、分家の際に才谷屋から多額の財産を分与されており、非常に裕福な家庭だった[\\[4\\]][\\[5\\]]。\n\n龍馬の父・坂本直足は[婿養子]として坂本家を継いだ人物で、[実祖父]の山本家（山本信固）や、その[弟]・[宮地信貞]（宮地家を相続）は共に白札郷士であり、龍馬は血統上は[上士]の人物である[\\[6\\]]。\n\n龍馬は幼少時、泣き虫で弱虫のひ弱な少年であった。実母の幸を10歳の時に病気で亡くす。以後、姉の[乙女]が母代わりに龍馬を教育する。12歳まで夜尿が直らなかったが、乙女が夜中に厠に起こして連れて行き克服させた。乙女は身長176cm、体重110kgを超える当時としては尋常ならざる体躯を持ち、剣術にも秀でていたため、龍馬の剣術師範も務めたと伝説的に語られる。龍馬は終生、乙女への感謝と恋慕を失わず、現存する龍馬直筆の乙女宛の手紙は16通残っている\\[_[要出典]_\\]。\n\n→詳細は「[坂本龍馬の系譜]」を参照\n\n" ';

      final result = await target.embed(
          EmbeddingModel.kclNagoyaRuriLarge(), message.substring(0, 256));
      expect(result.model, 'kun432/cl-nagoya-ruri-large:latest');
      expect(result.embeddings.length, greaterThan(0));
      expect(result.embeddings.first.length, greaterThan(0));
    });
  });
}
