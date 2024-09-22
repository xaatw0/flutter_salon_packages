class ChatModel {
  const ChatModel({
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
  final List<ChatMessageModel> messages;

  factory ChatModel.fromJson(Map<String, dynamic> json) {
    final messages = List<ChatMessageModel>.from(
        json['messages'].map((message) => ChatMessageModel.fromJson(message)))
      ..sort((e1, e2) => e1.dateTime.compareTo(e2.dateTime));

    return ChatModel(
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
}

class ChatMessageModel {
  const ChatMessageModel({
    required this.dateTime,
    required this.message,
    required this.response,
  });

  final DateTime dateTime;
  final String message;
  final String response;

  factory ChatMessageModel.fromJson(Map<String, dynamic> json) {
    return ChatMessageModel(
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

  ChatMessageModel withResponse(String newResponse) {
    return ChatMessageModel(
        dateTime: dateTime, message: message, response: newResponse);
  }
}
