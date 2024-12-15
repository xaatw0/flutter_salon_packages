import 'dart:async';

import 'package:http/http.dart' as http;
import 'package:mockito/mockito.dart';
import 'package:ollama_talk_common/ollama_talk_common.dart';
import 'package:ollama_talk_server/ollama_talk_server.dart';
import 'package:ollama_talk_server/src/infrastructures/ollama/data/tags_response_data.dart';
import 'package:ollama_talk_server/src/infrastructures/ollama/ollama_server.dart';
import 'package:test/test.dart';

import 'ollama_server_test.mocks.dart';

void main() {
  final target = OllamaServer(http.Client(), '192.168.1.33:5050/api');

  group('tags', () {
    test('取得: ollamaが起動していること', () async {
      final List<TagsResponseData> result = await target.tags();
      expect(result.length, isNot(0));
      result.forEach((e) => print(e.name));

      expect(result.where((e) => e.name == 'llama3:latest').length, 1);
    });
  });

  group('chat', () {
    test('stream=true', () async {
      final chatMessage = ChatRequestMessage(
          role: Role.user.name, content: 'Say only "Hello!"');
      final chatRequest =
          ChatRequestData(model: 'llama3:latest', messages: [chatMessage]);

      final completer = Completer<String>();
      final buffer = StringBuffer();
      target.chat(chatRequest).listen((data) {
        buffer.write(data.message?.content ?? '');
      }, onDone: () {
        completer.complete(buffer.toString());
      });

      expect(await completer.future, 'Hello!');
      print('result: ${await completer.future}');
    });

    test('stream=false', () async {
      final chatMessage = ChatRequestMessage(
          role: Role.user.name, content: 'Say only "Hello!"');
      final chatRequest =
          ChatRequestData(model: 'llama3:latest', messages: [chatMessage]);

      final response = await target.chatWithoutStream(chatRequest);
      expect(response.message?.content, 'Hello!');
    });

    test('ask question', () async {
      final chatMessage = ChatRequestMessage(
          role: Role.user.name, content: 'What is Flutter in 20 characters??');
      final chatRequest =
          ChatRequestData(model: 'llama3:latest', messages: [chatMessage]);

      final response = await target.chatWithoutStream(chatRequest);
      print(response.message?.content);
    });

    test('Series of questions', () async {
      final chatMessage1 = ChatRequestMessage(
          role: Role.user.name, content: 'What is Flutter in 30 characters');
      final chatRequest1 =
          ChatRequestData(model: 'llama3:latest', messages: [chatMessage1]);

      final response = await target.chatWithoutStream(chatRequest1);

      final chatMessage2 = ChatRequestMessage(
          role: Role.user.name,
          content:
              'How many points out of 100 is this answer? Output only the number');
      final chatRequest2 = ChatRequestData(model: 'llama3:latest', messages: [
        chatMessage1,
        ChatRequestMessage.fromData(response.toEntity()),
        chatMessage2,
      ]);
      final response2 = await target.chatWithoutStream(chatRequest2);
      print(response2.message?.content);
    });
  });
}
