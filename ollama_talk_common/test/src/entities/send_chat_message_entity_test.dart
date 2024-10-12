import 'package:ollama_talk_common/src/entities/send_chat_message_entity.dart';
import 'package:test/test.dart';

void main() {
  group('SendChatMessageEntity', () {
    test('1. Create class using constructor', () {
      // Create an instance using the constructor
      const sendChatMessageEntity = SendChatMessageEntity(
        prompt: 'Hello, how can I assist you?',
        chatId: 12345,
      );

      // Assertions
      expect(sendChatMessageEntity.prompt, 'Hello, how can I assist you?');
      expect(sendChatMessageEntity.chatId, 12345);
    });

    test('2. Create class from JSON and convert back to JSON', () {
      // JSON data
      final json = {
        'prompt': 'What is the weather today?',
        'chat_id': 67890,
      };

      // Create an instance from JSON
      final sendChatMessageEntity = SendChatMessageEntity.fromJson(json);

      // Assertions
      expect(sendChatMessageEntity.prompt, 'What is the weather today?');
      expect(sendChatMessageEntity.chatId, 67890);

      // Convert the instance back to JSON
      final jsonOutput = sendChatMessageEntity.toJson();

      // Assertions on the output JSON
      expect(jsonOutput['prompt'], 'What is the weather today?');
      expect(jsonOutput['chat_id'], 67890);
    });
  });
}
