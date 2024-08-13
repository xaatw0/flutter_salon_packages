import 'package:ollama_talk_server/ollama_talk_server.dart';
import 'package:test/test.dart';

import 'utility.dart';

void main() async {
  test('ChatHistoryEntity CRUD', () async {
    final store = await getStore();
    final chatBox = store.box<ChatEntity>();
    final chatHistoryBox = store.box<ChatMessageEntity>();

    final chat1 = ChatEntity(title: 'Chat Title 1', llmModel: 'model1');
    final chat2 = ChatEntity(title: 'Chat Title 2', llmModel: 'model1');
    final chatIds = await chatBox.putManyAsync([chat1, chat2]);
    expect(chatIds, [1, 2]);

    final chatHistory1_1 = ChatMessageEntity(
      dateTime: DateTime.now(),
      message: 'Message 1-1',
    )..chat.target = chat1;

    final chatHistory1_2 = ChatMessageEntity(
      dateTime: DateTime.now(),
      message: 'Message 1-2',
    )..chat.target = chat1;

    final chatHistory2 = ChatMessageEntity(
      dateTime: DateTime.now(),
      message: 'Message 2',
    )..chat.target = chat2;

    final historyIds = await chatHistoryBox
        .putManyAsync([chatHistory1_1, chatHistory1_2, chatHistory2]);
    expect(historyIds, [1, 2, 3]);

    final allChatHistories = chatHistoryBox.getAll();
    expect(allChatHistories.length, 3);
    expect(allChatHistories.map((e) => e.message).toSet(),
        {'Message 1-1', 'Message 1-2', 'Message 2'});

    final chatHistoryToUpdate = chatHistoryBox.get(historyIds[0])!;
    chatHistoryToUpdate.response = 'Response 1-1';
    await chatHistoryBox.putAsync(chatHistoryToUpdate);

    final updatedChatHistory = chatHistoryBox.get(historyIds[0])!;
    expect(updatedChatHistory.response, 'Response 1-1');

    // Delete ChatHistoryEntity
    final removeResult = await chatHistoryBox.removeAsync(historyIds[1]);
    expect(removeResult, true);
    expect(chatHistoryBox.getAll().length, 2);
    expect(chatHistoryBox.getAll().map((e) => e.message).toSet(),
        {'Message 1-1', 'Message 2'});

    store.close();
  });
}
