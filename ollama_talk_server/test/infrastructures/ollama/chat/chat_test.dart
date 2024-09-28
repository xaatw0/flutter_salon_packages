import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:ollama_talk_common/ollama_talk_common.dart';
import 'package:ollama_talk_server/ollama_talk_server.dart';
import 'package:ollama_talk_server/src/domain/service_locator.dart';
import 'package:ollama_talk_server/src/infrastructures/ollama/chat/chat.dart';
import 'package:test/test.dart';
import 'package:http/http.dart' as http;

import 'chat_test.mocks.dart';

@GenerateNiceMocks([
  MockSpec<http.Client>(),
  MockSpec<ServiceLocator>(),
  MockSpec<http.StreamedResponse>(),
])
void main() {
  Future<Store> getStore() async {
    await Future.delayed(const Duration(milliseconds: 10));
    return openStore(
        directory:
            'memory:object-box-${DateTime.now().millisecondsSinceEpoch}');
  }

  group('constructor', () {
    test('create', () async {
      final mock = MockServiceLocator();

      when(mock.store).thenReturn(await getStore());
      ServiceLocator.setMock(mock);

      final store = ServiceLocator.instance.store;
      final all0 = store.box<ChatEntity>().getAll();
      expect(all0.length, 0);

      final target = Chat.create(LlmModel('llmModel'));
      await target.save();
      final all1 = store.box<ChatEntity>().getAll();
      expect(all1.length, 1);

      final first = all1.first;
      expect(first.llmModel, 'llmModel');
      expect(first.messages.length, 0);
      expect(first.id, isNot(0));
    });
  });

  group('ObjectBox', () {
    test('create, add message, load', () async {
      final mock = MockServiceLocator();

      when(mock.store).thenReturn(await getStore());
      ServiceLocator.setMock(mock);

      final store = ServiceLocator.instance.store;
      expect(store.box<ChatEntity>().getAll().length, 0);

      // create chat1 and check save
      final chat1 = Chat.create(LlmModel('llmModel'));
      final chat1Registered = await chat1.save();
      expect(chat1Registered.chat.id, isNot(0));

      final message1 = ChatMessageEntity(
          message: 'message1', dateTime: DateTime(2024, 1, 1, 1));
      expect(chat1Registered.messages.length, 0);
      chat1Registered.addMessage(message1);
      expect(chat1Registered.messages.length, 1);

      final message2 = ChatMessageEntity(
          message: 'message2', dateTime: DateTime(2024, 1, 1, 2));
      chat1Registered.addMessage(message2);
      expect(chat1Registered.messages.length, 2);

      expect(store.box<ChatMessageEntity>().getAll().length, 0);

      final chatWithMessages = await chat1Registered.save();
      expect(chatWithMessages.messages.length, 2);
      expect(store.box<ChatMessageEntity>().getAll().length, 2);

      // create chat2
      final chat2 = Chat.create(LlmModel('llmModel'));
      final message3 = ChatMessageEntity(
          message: 'message3', dateTime: DateTime(2024, 1, 1, 2));
      chat2.addMessage(message3);
      final newChat2 = await chat2.save();
      expect(newChat2.messages.length, 1);

      expect(store.box<ChatEntity>().getAll().length, 2);
      expect(store.box<ChatMessageEntity>().getAll().length, 3);

      final loadedChat1 = Chat.load(chat1Registered.chat.id);
      expect(loadedChat1.chat.id, chat1Registered.chat.id);
      expect(loadedChat1.messages.length, 2);
      expect(loadedChat1.messages[0].message, 'message1');
      expect(loadedChat1.messages[1].message, 'message2');

      expect(loadedChat1.chat.title, '');
      loadedChat1.setTitle('title');
      final chat1WithTitle = loadedChat1..save();
      expect(chat1WithTitle.chat.title, 'title');
    });
  });

  group('Ollama', () {
    test('', () async {
      final mock = MockServiceLocator();

      when(mock.store).thenReturn(await getStore());
      ServiceLocator.setMock(mock);

      final store = ServiceLocator.instance.store;
      expect(store.box<ChatEntity>().getAll().length, 0);

      final mockClient = MockClient();
      when(mock.httpClient).thenReturn(mockClient);
      final mockStream = MockStreamedResponse();

//      final http.ByteStream1 = http.ByteStream(stream);
      //    when(mockStream.stream).thenReturnInOrder([]);
      //  when(mockClient.send(any)).thenAnswer((_)=>)
    });
  });
}
