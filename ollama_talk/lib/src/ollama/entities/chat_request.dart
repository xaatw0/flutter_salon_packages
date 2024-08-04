import 'package:ollama_talk/ollama_talk.dart';

enum Role { user, assistant, system }

class ChatRequest {
  final LlmModel model;
  final List<Message> messages;

  ChatRequest({
    required this.model,
    required this.messages,
    //this.stream = true,
    //this.tools,
    //this.advancedParameters,
  });

  Map<String, dynamic> toJson() => {
        'model': model.value,
        'messages': messages.map((message) => message.toJson()).toList(),
        //  'stream': stream,
        //  if (tools != null) 'tools': tools!.toJson(),
        //   if (advancedParameters != null) 'options': advancedParameters!.toJson(),
      };
}

class Message {
  final Role role;
  final String content;
  // final List<String>? images;
  // final List<String>? toolCalls;

  Message({
    required this.role,
    required this.content,
    //this.images,
    //this.toolCalls,
  });

  static List<Message> fromChatMessageEntity(ChatMessageEntity entity) {
    return [
      Message(role: Role.user, content: entity.message),
      Message(role: Role.assistant, content: entity.response),
    ];
  }

  Map<String, dynamic> toJson() => {
        'role': role.toString().split('.').last, // Enumを文字列に変換
        'content': content,
        //  if (images != null) 'images': images,
        //   if (toolCalls != null) 'tool_calls': toolCalls,
      };

  factory Message.fromJson(Map<String, dynamic> json) {
    return Message(
      role: Role.values
          .firstWhere((e) => e.toString().split('.').last == json['role']),
      content: json['content'],
      //images: json['images'] != null ? List<String>.from(json['images']) : null,
      // toolCalls: json['tool_calls'] != null
      //  ? List<String>.from(json['tool_calls'])
      //   : null,
    );
  }
}

class Tools {
  final String toolName;
  final Map<String, dynamic> parameters;

  Tools({
    required this.toolName,
    required this.parameters,
  });

  Map<String, dynamic> toJson() => {
        'tool_name': toolName,
        'parameters': parameters,
      };
}

class AdvancedParameters {
  final String? format;
  final int? temperature;
  final int? keepAlive;

  AdvancedParameters({
    this.format,
    this.temperature,
    this.keepAlive,
  });

  Map<String, dynamic> toJson() => {
        if (format != null) 'format': format,
        if (temperature != null) 'temperature': temperature,
        if (keepAlive != null) 'keep_alive': keepAlive,
      };
}
