import 'package:mockito/annotations.dart';
import 'package:ollama_talk_common/ollama_talk_common.dart';
import 'package:ollama_talk_server/src/domain/agents/abstract_agent.dart';
import 'package:ollama_talk_server/src/domain/agents/llm_agent.dart';
import 'package:ollama_talk_server/src/infrastructures/ollama/data/generate_response.dart';
import 'package:test/test.dart';
import 'package:mockito/mockito.dart';
import 'package:ollama_talk_server/ollama_talk_server.dart';
import 'package:ollama_talk_server/src/domain/service_locator.dart';
import 'package:http/http.dart' as http;
import 'package:ollama_talk_server/src/infrastructures/ollama/ollama_server.dart';
import 'llm_agent_test.mocks.dart';

@GenerateNiceMocks([
  MockSpec<http.Client>(),
  MockSpec<ServiceLocator>(),
  MockSpec<OllamaServer>(),
  MockSpec<TalkServer>(),
  MockSpec<ChatResponseData>(),
])
void main() {
  final serviceLocator = MockServiceLocator();
  final ollamaServer = MockOllamaServer();
  final talkServer = MockTalkServer();

  when(serviceLocator.ollamaTalkServer).thenReturn(talkServer);
  when(talkServer.ollamaServer).thenReturn(ollamaServer);
  ServiceLocator.setMock(serviceLocator);

  group('LlmAgent', () {
    test('HandleReplies.append', () async {
      when(ollamaServer.generateWithFuture('model', 'prompt1\nabc'))
          .thenAnswer((_) async {
        return GenerateResponseData(
          model: 'model',
          createdAt: DateTime.now(),
          done: true,
          response: 'def',
        );
      });

      final llmAgent1 = LlmAgent(LlmModel('model'), 'prompt1');
      final response = await llmAgent1.input('abc');
      expect(response.message, 'abc\ndef');
    });

    test('HandleReplies.replace', () async {
      when(ollamaServer.generateWithFuture('model', 'prompt2\nabc'))
          .thenAnswer((_) async {
        return GenerateResponseData(
          model: 'model',
          createdAt: DateTime.now(),
          done: true,
          response: 'def',
        );
      });

      final llmAgent1 = LlmAgent(LlmModel('model'), 'prompt2');
      final response = await llmAgent1.input('abc');
      expect(response.message, 'def');
    });
  });

  group('ChainOfResponsibility', () {
    test('setNext', () async {
      when(ollamaServer.generateWithFuture('model', 'prompt1\nabc'))
          .thenAnswer((_) async {
        return GenerateResponseData(
          model: 'model',
          createdAt: DateTime.now(),
          done: true,
          response: 'def',
        );
      });

      when(ollamaServer.generateWithFuture('model', 'prompt2\nabc'))
          .thenAnswer((_) async {
        return GenerateResponseData(
          model: 'model',
          createdAt: DateTime.now(),
          done: true,
          response: 'def',
        );
      });

      when(ollamaServer.generateWithFuture('model', 'prompt3\ndef'))
          .thenAnswer((_) async {
        return GenerateResponseData(
          model: 'model',
          createdAt: DateTime.now(),
          done: true,
          response: 'ghi',
        );
      });

      final agents = LlmAgent(LlmModel('model'), 'prompt1')
        ..setNext(LlmAgent(LlmModel('model'), 'prompt2'))
        ..setNext(LlmAgent(LlmModel('model'), 'prompt3'));

      final response = await agents.input('abc');
      expect(response.message, 'def\nghi');
    });
  });
}
