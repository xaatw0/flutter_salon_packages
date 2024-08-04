import 'package:objectbox/objectbox.dart'; // needed before generate
import 'package:ollama_talk/ollama_talk.dart';
import 'package:ollama_talk/src/ollama/entities/chat_request.dart';
import '../../objectbox.g.dart'; // auto generated file

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
  final Message systemMessage;

  ChatEntity({
    this.title = kNoTitle,
    required this.llmModel,
    this.system = '',
  }) : systemMessage = Message(role: Role.system, content: system);

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

  Message? getSystemMessage() {
    return system.isEmpty ? null : systemMessage;
  }

  ChatRequest request(List<Message> messages) {
    return ChatRequest(model: LlmModel(llmModel), messages: messages);
  }
}
