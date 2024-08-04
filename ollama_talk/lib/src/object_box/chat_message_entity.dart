import 'package:objectbox/objectbox.dart';
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
    Store store,
    String newPartForResponse,
    bool done,
  ) {
    response = response + newPartForResponse;
    isDone = done;
    store.box<ChatMessageEntity>().put(this);
  }
}
