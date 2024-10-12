import 'dart:io';

import 'package:dart_frog/dart_frog.dart';
import 'package:mocktail/mocktail.dart';
import 'package:ollama_talk_common/ollama_talk_common.dart';
import 'package:ollama_talk_server/ollama_talk_server.dart';
import 'package:test/test.dart';

import '../../routes/tags.dart' as route;

class _MockRequestContext extends Mock implements RequestContext {}

class _MockOllamaTalkClient extends Mock implements TalkServer {}

void main() {
  group('GET /tags', () {
    test('responds with a 200', () async {
      final context = _MockRequestContext();
      final ollama = _MockOllamaTalkClient();
      when(() => context.read<TalkServer>()).thenAnswer((_) => ollama);
      when(() => ollama.loadLocalLlmModels()).thenAnswer((_) =>
          Future.value(<LlmModel>[LlmModel('model1'), LlmModel('model2')]));

      final source = '{"models":["model1","model2"]}';
      final response = await route.onRequest(context);
      expect(response.statusCode, equals(HttpStatus.ok));
      expect(
        response.body(),
        completion(equals(source)),
      );
    });
  });
}
