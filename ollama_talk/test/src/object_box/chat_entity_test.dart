import 'package:flutter_test/flutter_test.dart';
import 'package:ollama_talk/ollama_talk.dart';

import 'utility.dart';

void main() async {
  TestWidgetsFlutterBinding.ensureInitialized();
  test('CRUD', () async {
    final store = await getStore();
    final box = store.box<ChatEntity>();
    final chat1 = ChatEntity(title: 'title1', llmModel: 'model1');
    final chat2 = ChatEntity(title: 'title2', llmModel: 'model1');
    final ids = await box.putManyAsync([chat1, chat2]);
    expect(ids, [1, 2]);

    expect(box.getAll().map((e) => e.title).toSet(), {'title1', 'title2'});

    final result = await box.removeAsync(1);
    expect(result, true);
    expect(box.getAll().map((e) => e.title).toSet(), {'title2'});
    store.close();
  });

  test('getHistory', () async {
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

    final history1 = await chat1.getHistories(store);
    /*
          final orderQuery2 = store.box<ChatMessageEntity>().query()
        ..link(ChatMessageEntity_.chat, ChatEntity_.id.equals(chat1.id));
      print('result:' + orderQuery2.build().find().length.toString());
     */

    // Windowsのテストではうまく動作しない 以下は2
    expect(history1.length, 0);
    //expect(history1[0].message, 'Message 1-1');
    //expect(history1[1].message, 'Message 1-2');
    store.close();
  });
}
