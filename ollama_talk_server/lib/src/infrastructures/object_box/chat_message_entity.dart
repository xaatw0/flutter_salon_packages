import 'package:objectbox/objectbox.dart';
import 'package:ollama_talk_server/src/domain/service_locator.dart';
import 'chat_entity.dart';

@Entity()
class ChatMessageEntity {
  @Id()
  int id = 0;

  @Property(type: PropertyType.date)
  DateTime dateTime;
  String message;
  String response;
  bool isDone = false;
  final chat = ToOne<ChatEntity>();

  ChatMessageEntity({
    required this.dateTime,
    required this.message,
    this.response = '',
  });

  void receiveResponse(
    String newPartForResponse,
    bool done,
  ) {
    response = response + newPartForResponse;
    isDone = done;
  }

  Future<int> save() {
    return ServiceLocator.instance.store
        .box<ChatMessageEntity>()
        .putAsync(this);
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'dateTime': dateTime.toIso8601String(),
      'message': message,
      'response': response,
      'isDone': isDone,
      'chatId': chat.targetId,
    };
  }
}
