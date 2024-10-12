import 'package:objectbox/objectbox.dart';
import 'package:ollama_talk_server/src/domain/service_locator.dart';
import 'chat_box.dart';

@Entity()
class ChatMessageBox {
  @Id()
  int id = 0;

  @Property(type: PropertyType.date)
  DateTime dateTime;
  String message;
  String response;
  bool isDone = false;
  final chat = ToOne<ChatBox>();

  ChatMessageBox({
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

  Future<ChatMessageBox> save(Store store) async {
    final id = store.box<ChatMessageBox>().putAsync(this);
    return store.box<ChatMessageBox>().get(await id)!;
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
