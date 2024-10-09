import 'package:collection/collection.dart';

class ChatEntity {
  const ChatEntity({
    required this.id,
    required this.title,
    required this.llmModel,
    required this.system,
    required this.messages,
  });

  final int id;
  final String title;
  final String llmModel;
  final String system;
  final List<ChatMessageEntity> messages;

  factory ChatEntity.fromJson(Map<String, dynamic> json) {
    final messages = List<ChatMessageEntity>.from(
        json['messages'].map((message) => ChatMessageEntity.fromJson(message)))
      ..sort((e1, e2) => e1.dateTime.compareTo(e2.dateTime));

    return ChatEntity(
      id: json['id'],
      title: json['title'],
      llmModel: json['llm_model'],
      system: json['system'],
      messages: messages,
    );
  }

  // Method to convert an instance to a JSON map
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'llm_model': llmModel,
      'system': system,
      'messages':
          List<dynamic>.from(messages.map((message) => message.toJson())),
    };
  }

  // equalsメソッド
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other.runtimeType != runtimeType) return false;
    final ChatEntity otherEntity = other as ChatEntity;
    return id == otherEntity.id &&
        title == otherEntity.title &&
        llmModel == otherEntity.llmModel &&
        system == otherEntity.system &&
        ListEquality().equals(messages, otherEntity.messages);
  }

  // hashCodeメソッド
  @override
  int get hashCode {
    return Object.hash(
      id,
      title,
      llmModel,
      system,
      ListEquality().hash(messages),
    );
  }

  ChatEntity copyWith({
    String? title,
  }) {
    return ChatEntity(
      id: id,
      title: title ?? this.title,
      llmModel: llmModel,
      system: system,
      messages: messages,
    );
  }
}

class ChatMessageEntity {
  const ChatMessageEntity({
    required this.dateTime,
    required this.message,
    required this.response,
  });

  final DateTime dateTime;
  final String message;
  final String response;

  factory ChatMessageEntity.fromJson(Map<String, dynamic> json) {
    return ChatMessageEntity(
      dateTime: DateTime.parse(json['date_time']),
      message: json['message'],
      response: json['response'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'date_time': dateTime.toIso8601String(),
      'message': message,
      'response': response,
    };
  }

  ChatMessageEntity withResponse(String newResponse) {
    return ChatMessageEntity(
        dateTime: dateTime, message: message, response: newResponse);
  }
}
