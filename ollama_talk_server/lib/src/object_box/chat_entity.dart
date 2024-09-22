import 'package:ollama_talk_common/ollama_talk_common.dart';

import 'package:objectbox/objectbox.dart'; // needed for generate
import '../../objectbox.g.dart'; // auto generate file
import '../ollama/entities/chat_request_entity.dart';
import 'chat_message_entity.dart';
import 'package:ollama_talk_common/ollama_talk_common.dart';

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

  ChatModel toChatModel() {
    final chatMessage = messages.map(
      (e) => ChatMessageModel(
        dateTime: e.dateTime,
        message: e.message,
        response: e.response,
      ),
    );

    return ChatModel(
      id: id,
      title: title,
      llmModel: llmModel,
      system: system,
      messages: chatMessage.toList(),
    );
  }

  ChatModel toSummary() {
    final chatMessage = messages.map(
      (e) => ChatMessageModel(
        dateTime: e.dateTime,
        message: e.message,
        response: e.response,
      ),
    );

    return ChatModel(
      id: id,
      title: title,
      llmModel: llmModel,
      system: '',
      messages: [],
    );
  }

  void pushMessage(Store store, ChatMessageEntity messageEntity) {
    messageEntity.chat.target = this;
    store.box<ChatMessageEntity>().put(messageEntity);
  }
}
