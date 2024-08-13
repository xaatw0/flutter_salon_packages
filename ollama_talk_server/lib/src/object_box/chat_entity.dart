import 'package:ollama_talk_common/value_objects.dart';

import '../../objectbox.g.dart'; // auto generate file
import '../ollama/entities/chat_request_entity.dart';
import 'chat_message_entity.dart';

@Entity()
class ChatEntity {
  @Id()
  int id = 0;

  static const kNoTitle = 'No title';

  String title;

  String llmModel;

  String system;

  final messages = ToMany<ChatMessageEntity>();

  @Transient()
  final MessageEntity systemMessage;

  ChatEntity({
    this.title = kNoTitle,
    required this.llmModel,
    this.system = '',
  }) : systemMessage = MessageEntity(role: Role.system, content: system);

  Future<List<ChatMessageEntity>> getHistories(
    Store store, {
    int limit = 10,
  }) async {
    final orderQuery = store
        .box<ChatMessageEntity>()
        .query()
        .order(ChatMessageEntity_.id, flags: Order.descending);

    orderQuery.link(ChatMessageEntity_.chat, ChatEntity_.id.equals(id));

    return (orderQuery.build()..limit = limit).find();
  }

  ChatMessageEntity sendMessage(
      Store store, String message, DateTime dateTime) {
    final messageEntity =
        ChatMessageEntity(dateTime: dateTime, message: message);
    messageEntity.chat.target = this;

    store.box<ChatMessageEntity>().put(messageEntity);
    return messageEntity;
  }

  MessageEntity? getSystemMessage() {
    return system.isEmpty ? null : systemMessage;
  }

  ChatRequestEntity request(List<MessageEntity> messages) {
    return ChatRequestEntity(model: LlmModel(llmModel), messages: messages);
  }
}
