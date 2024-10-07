import 'dart:convert';
import 'dart:io';

import 'package:mockito/annotations.dart';
import 'package:http/http.dart' as http;
import 'package:mockito/mockito.dart';
import 'package:ollama_talk_server/ollama_talk_server.dart';
import 'package:ollama_talk_server/src/infrastructures/ollama/ollama_server.dart';
import 'package:test/test.dart';

import 'ollama_server_test.mocks.dart';

@GenerateNiceMocks([MockSpec<http.Client>()])
void main() {
  final client = MockClient();
  final target = OllamaServer(client, 'localhost:11434/api');

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
}
