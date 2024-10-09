import 'package:ollama_talk_common/ollama_talk_common.dart';
import 'package:objectbox/objectbox.dart';
import '../../../objectbox.g.dart'; // auto generate file
import 'package:ollama_talk_server/src/domain/service_locator.dart';

import 'chat_message_box.dart';

@Entity()
class ChatBox {
  @Id()
  int id = 0;

  static const kNoTitle = 'No title';

  String title;

  String llmModel;

  String system;

  final messages = ToMany<ChatMessageBox>();

  @Transient()
  final MessageData systemMessage;

  ChatBox({
    this.title = '',
    required this.llmModel,
    this.system = '',
  }) : systemMessage = MessageData(Role.system, system);

  Future<List<ChatMessageBox>> getHistories(
    Store store, {
    int limit = 10,
  }) async {
    final orderQuery = store
        .box<ChatMessageBox>()
        .query()
        .order(ChatMessageBox_.id, flags: Order.descending);

    orderQuery.link(ChatMessageBox_.chat, ChatBox_.id.equals(id));

    return (orderQuery.build()..limit = limit).find();
  }

  ChatMessageBox sendMessage(Store store, String message, DateTime dateTime) {
    final messageEntity = ChatMessageBox(dateTime: dateTime, message: message);
    messageEntity.chat.target = this;

    store.box<ChatMessageBox>().put(messageEntity);
    return messageEntity;
  }

  MessageData? getSystemMessage() {
    return system.isEmpty ? null : systemMessage;
  }

  ChatEntity toChatEntity() {
    final chatMessage = messages.map(
      (e) => ChatMessageEntity(
        dateTime: e.dateTime,
        message: e.message,
        response: e.response,
      ),
    );

    return ChatEntity(
      id: id,
      title: title,
      llmModel: llmModel,
      system: system,
      messages: chatMessage.toList(),
    );
  }

  ChatEntity toSummary() {
    return ChatEntity(
      id: id,
      title: title,
      llmModel: llmModel,
      system: '',
      messages: [],
    );
  }

  Future<int> pushMessage(Store store, ChatMessageBox messageEntity) {
    messageEntity.chat.target = this;
    return store.box<ChatMessageBox>().putAsync(messageEntity);
  }

  Future<ChatBox> save(Store store) async {
    final id = store.box<ChatBox>().putAsync(this);
    return store.box<ChatBox>().get(await id)!;
  }
}
