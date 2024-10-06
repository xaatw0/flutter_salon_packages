import 'dart:async';

import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:ollama_talk_common/ollama_talk_common.dart';
import 'package:ollama_talk_server/ollama_talk_server.dart';
import 'package:ollama_talk_server/src/domain/service_locator.dart';
import 'package:http/http.dart' as http;
import 'package:ollama_talk_server/src/infrastructures/ollama/ollama_server.dart';
import 'package:test/test.dart';

import '../infrastructures/object_box/utility.dart';
import 'server_test.mocks.dart';

@GenerateNiceMocks([
  MockSpec<http.Client>(),
  MockSpec<ServiceLocator>(),
  MockSpec<OllamaServer>(),
  MockSpec<ChatResponseModel>(),
])
void main() {
  test('chat(sendMessageWithoutStream)のテスト', () async {
    final mockClient = MockClient();
    when(mockClient.get(Uri.parse('http://test.com/index')))
        .thenAnswer((_) async => http.Response('body', 200));

    final store = await getStore();

    final mock = MockServiceLocator();
    when(mock.apiRoot).thenReturn('test.com');
    when(mock.httpClient).thenReturn(mockClient);
    when(mock.store).thenReturn(store);

    ServiceLocator.setMock(mock);

    final mockOllama = MockOllamaServer();

    final server = TalkServer(mockClient, 'test.com', store, mockOllama);
    expect(store.box<ChatEntity>().getAll().length, 0);
    final chatId1 = await server.openChat('llm_model', 'system message');
    expect(store.box<ChatEntity>().getAll().length, 1);

    final chat1 = store.box<ChatEntity>().get(chatId1)!;
    expect(chat1.llmModel, 'llm_model');
    expect(chat1.system, 'system message');
    expect(chat1.messages.length, 0);

    final chatRequest1 = ChatRequestModel(
        model: 'llm_model',
        messages: [
          ChatRequestMessage(
              role: 'system', content: 'system message', images: const []),
          ChatRequestMessage(
              role: 'user', content: 'prompt1', images: const []),
        ],
        options: null);
    when(mockOllama.chatWithoutStream(chatRequest1)).thenAnswer((_) async =>
        ChatResponseModel(
            model: 'llm_model',
            createdAt: DateTime(2024, 1, 1, 0, 0, 1),
            message:
                ChatResponseMessage(role: 'assistant', content: 'response1'),
            done: true));

    DateTime now = DateTime(2024, 1, 1, 0, 0, 0);
    final message_id1 =
        await server.sendMessageWithoutStream(chat1, 'prompt1', dateTime: now);

    final message1 = store.box<ChatMessageEntity>().get(message_id1);
    expect(message1, isNotNull);
    expect(message1?.message, 'prompt1');
    expect(message1?.response, 'response1');

    final chatRequest2 = ChatRequestModel(
        model: 'llm_model',
        messages: [
          ChatRequestMessage(
              role: 'system', content: 'system message', images: const []),
          ChatRequestMessage(
              role: 'user', content: 'prompt1', images: const []),
          ChatRequestMessage(
              role: 'assistant', content: 'response1', images: const []),
          ChatRequestMessage(
              role: 'user', content: 'prompt2', images: const []),
        ],
        options: null);
    when(mockOllama.chatWithoutStream(chatRequest2)).thenAnswer((_) async =>
        ChatResponseModel(
            model: 'llm_model',
            createdAt: DateTime(2024, 1, 1, 0, 0, 1),
            message:
                ChatResponseMessage(role: 'assistant', content: 'response2'),
            done: true));
    final message_id2 =
        await server.sendMessageWithoutStream(chat1, 'prompt2', dateTime: now);

    final message2 = store.box<ChatMessageEntity>().get(message_id2);
    expect(message2, isNotNull);
    expect(message2?.message, 'prompt2');
    expect(message2?.response, 'response2');

    final chatId2 = await server.openChat('llm_model', 'system message');
    final chat2 = store.box<ChatEntity>().get(chatId2)!;
    await server.sendMessageWithoutStream(chat2, 'prompt1', dateTime: now);

    expect(store.box<ChatEntity>().getAll().length, 2);

    final messages = store.box<ChatMessageEntity>().getAll();
    expect(messages.length, 3);
    expect(messages.where((e) => e.chat.target?.id == chatId1).length, 2);
    expect(messages.where((e) => e.chat.target?.id == chatId2).length, 1);
  });

  test('chat(sendMessage)のテスト', () async {
    final mockClient = MockClient();
    when(mockClient.get(Uri.parse('http://test.com/index')))
        .thenAnswer((_) async => http.Response('body', 200));

    final store = await getStore();

    final mock = MockServiceLocator();
    when(mock.apiRoot).thenReturn('test.com');
    when(mock.httpClient).thenReturn(mockClient);
    when(mock.store).thenReturn(store);

    ServiceLocator.setMock(mock);

    final mockOllama = MockOllamaServer();

    final server = TalkServer(mockClient, 'test.com', store, mockOllama);
    expect(store.box<ChatEntity>().getAll().length, 0);
    final chatId1 = await server.openChat('llm_model', 'system message');
    expect(store.box<ChatEntity>().getAll().length, 1);

    final chat1 = store.box<ChatEntity>().get(chatId1)!;
    expect(chat1.llmModel, 'llm_model');
    expect(chat1.system, 'system message');
    expect(chat1.messages.length, 0);

    final chatRequest1 = ChatRequestModel(
        model: 'llm_model',
        messages: [
          ChatRequestMessage(
              role: 'system', content: 'system message', images: const []),
          ChatRequestMessage(
              role: 'user', content: 'prompt1', images: const []),
        ],
        options: null);

    final datetime = DateTime(2024, 1, 1);
    final controller = StreamController<ChatResponseModel>();

    when(mockOllama.chat(chatRequest1)).thenAnswer((_) => controller.stream);

    final messageId = Completer<int>();

    DateTime now = DateTime(2024, 1, 1, 0, 0, 0);
    final stream = server.sendMessage(
      chat1,
      'prompt1',
      dateTime: now,
      messageId: messageId,
    );
    expectLater(
      stream,
      emitsInOrder(['response1', 'response2', emitsDone]),
    );

    controller.add(ChatResponseModel(
        model: 'llm_model',
        createdAt: datetime,
        message: ChatResponseMessage(role: 'assistant', content: 'response1'),
        done: false));
    controller.add(ChatResponseModel(
        model: 'llm_model',
        createdAt: datetime,
        message: ChatResponseMessage(role: 'assistant', content: 'response2'),
        done: false));
    controller.add(ChatResponseModel(
        model: 'llm_model', createdAt: datetime, done: true, message: null));
    controller.close();

    final message = store.box<ChatMessageEntity>().get(await messageId.future);
    expect(message, isNotNull);
    expect(message?.message, 'prompt1');
    expect(message?.response, 'response1response2');

    expect(chat1.messages.length, 1);
    expect(chat1.messages[0].message, 'prompt1');
    expect(chat1.messages[0].response, 'response1response2');
  });
}
