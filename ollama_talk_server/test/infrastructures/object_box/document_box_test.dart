import 'package:ollama_talk_server/ollama_talk_server.dart';
import 'package:test/test.dart';

import 'utility.dart';

void main() async {
  test('CRUD', () async {
    final store = await getStore();
    final box = store.box<ChatBox>();
    final chat1 = ChatBox(title: 'title1', llmModel: 'model1');
    final chat2 = ChatBox(title: 'title2', llmModel: 'model1');
    final ids = await box.putManyAsync([chat1, chat2]);
    expect(ids, [1, 2]);

    expect(box.getAll().map((e) => e.title).toSet(), {'title1', 'title2'});

    final result = await box.removeAsync(1);
    expect(result, true);
    expect(box.getAll().map((e) => e.title).toSet(), {'title2'});
    store.close();
  });
}
