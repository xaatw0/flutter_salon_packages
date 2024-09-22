import 'dart:io';

import 'package:dart_frog/dart_frog.dart';
import 'package:mocktail/mocktail.dart';
import 'package:ollama_talk_server/ollama_talk_server.dart';
import 'package:test/test.dart';

import '../../routes/tags.dart' as route;

class _MockRequestContext extends Mock implements RequestContext {}

class _MockOllamaTalkClient extends Mock implements OllamaTalkServer {}

void main() {
  group('GET /tags', () {
    test('responds with a 200', () async {
      final context = _MockRequestContext();
      final ollama = _MockOllamaTalkClient();
      when(() => context.read<Future<OllamaTalkServer>>())
          .thenAnswer((_) => Future.value(ollama));

      final llmDetailsEntity = LlmDetailsEntity(
        format: 'gguf',
        family: 'llama',
        families: [],
        parameterSize: '13B',
        quantizationLevel: 'Q4_0',
      );
      when(() => ollama.loadLocalModels()).thenAnswer((_) async => <LlmEntity>[
            LlmEntity(
              name: 'model1',
              modifiedAt: DateTime.parse('2023-11-04T14:56:49.277302595-07:00'),
              size: 7365960935,
              digest: '',
              details: llmDetailsEntity,
            ),
            LlmEntity(
              name: 'model2',
              modifiedAt: DateTime.parse('2023-11-04T14:56:49.277302595-07:00'),
              size: 7365960935,
              digest: '',
              details: llmDetailsEntity,
            )
          ]);

      final source = '{\"models\":[\"model1\",\"model2\"]}';
      final response = await route.onRequest(context);
      expect(response.statusCode, equals(HttpStatus.ok));
      expect(
        response.body(),
        completion(equals(source)),
      );
    });
  });
}
