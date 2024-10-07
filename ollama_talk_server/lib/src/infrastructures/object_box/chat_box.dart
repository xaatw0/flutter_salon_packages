import 'package:ollama_talk_common/ollama_talk_common.dart';
import 'package:objectbox/objectbox.dart';
import '../../../objectbox.g.dart'; // auto generate file
import 'package:ollama_talk_server/src/domain/service_locator.dart';

import 'chat_message_box.dart';
import 'package:ollama_talk_common/src/data/message_data.dart';

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
        .order(ChatMessageEntity_.id, flags: Order.descending);

    orderQuery.link(ChatMessageEntity_.chat, ChatEntity_.id.equals(id));

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
    return ChatModel(
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

  Future<int> save() {
    return ServiceLocator.instance.store.box<ChatBox>().putAsync(this);
  }
}
