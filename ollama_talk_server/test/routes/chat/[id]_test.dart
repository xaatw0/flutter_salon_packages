import 'dart:convert';
import 'dart:io';

import 'package:dart_frog/dart_frog.dart';
import 'package:mocktail/mocktail.dart';
import 'package:ollama_talk_common/ollama_talk_common.dart';
import 'package:ollama_talk_server/ollama_talk_server.dart';
import 'package:test/test.dart';

import '../../../routes/chat/[id].dart' as route;

class _MockRequestContext extends Mock implements RequestContext {}

class _MockOllamaTalkClient extends Mock implements TalkServer {}

class _MockRequest extends Mock implements Request {}

void main() {
  group('Post', () {
    test('updateTitle', () async {
      final context = _MockRequestContext();
      final ollama = _MockOllamaTalkClient();
      final request = _MockRequest();

      when(() => context.read<TalkServer>()).thenAnswer((_) => ollama);
      when(() => context.request).thenAnswer((_) => request);
      when(() => request.method).thenAnswer((_) => HttpMethod.post);
      when(() => request.body())
          .thenAnswer((_) async => jsonEncode({'title': 'good title'}));

      when(() => ollama.loadChat(1))
          .thenAnswer((_) async => ChatBox(llmModel: 'llmModel'));
      when(() => ollama.updateTitle(1, 'good title')).thenAnswer(
          (_) async => ChatBox(llmModel: 'llmModel', title: 'good title'));

      final expected = ChatBox(llmModel: 'llmModel', title: 'good title');
      final response = await route.onRequest(context, '1');
      expect(response.statusCode, equals(HttpStatus.ok));
      expect(
        ChatEntity.fromJson(jsonDecode(await response.body())),
        expected.toChatEntity(),
      );
    });

    test('not found', () async {
      final context = _MockRequestContext();
      final ollama = _MockOllamaTalkClient();
      final request = _MockRequest();

      when(() => context.read<TalkServer>()).thenAnswer((_) => ollama);
      when(() => context.request).thenAnswer((_) => request);
      when(() => request.method).thenAnswer((_) => HttpMethod.post);
      when(() => request.body())
          .thenAnswer((_) async => jsonEncode({'title': 'good title'}));

      when(() => ollama.loadChat(1)).thenAnswer((_) async => null);

      final response = await route.onRequest(context, '1');
      expect(response.statusCode, equals(HttpStatus.notFound));
    });
  });
}
