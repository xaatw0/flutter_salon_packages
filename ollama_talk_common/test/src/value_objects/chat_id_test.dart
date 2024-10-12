import 'package:ollama_talk_common/src/value_objects/chat_id.dart';
import 'package:test/test.dart';

void main() {
  test('json', () {
    final chatId = ChatId(0);
    expect(chatId.value, 0);

    final source = chatId.toJson();
    expect(ChatId.fromJson(source).value, 0);
  });
}
