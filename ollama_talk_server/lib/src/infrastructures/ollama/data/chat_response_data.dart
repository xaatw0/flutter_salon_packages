import 'package:ollama_talk_common/ollama_talk_common.dart';

/// Response for Generate a chat completion
/// https://github.com/ollama/ollama/blob/main/docs/api.md#generate-a-chat-completion
class ChatResponseData {
  final String model;
  final DateTime createdAt;
  final ChatResponseMessage? message;
  final bool done;
  final int? totalDuration;
  final int? loadDuration;
  final int? promptEvalCount;
  final int? promptEvalDuration;
  final int? evalCount;
  final int? evalDuration;

  ChatResponseData({
    required this.model,
    required this.createdAt,
    required this.message,
    required this.done,
    this.totalDuration,
    this.loadDuration,
    this.promptEvalCount,
    this.promptEvalDuration,
    this.evalCount,
    this.evalDuration,
  });

  factory ChatResponseData.fromJson(Map<String, dynamic> json) {
    return ChatResponseData(
      model: json['model'],
      createdAt: DateTime.parse(json['created_at']),
      message: json['message'] == null
          ? null
          : ChatResponseMessage.fromJson(json['message']),
      done: json['done'],
      totalDuration: json['total_duration'],
      loadDuration: json['load_duration'],
      promptEvalCount: json['prompt_eval_count'],
      promptEvalDuration: json['prompt_eval_duration'],
      evalCount: json['eval_count'],
      evalDuration: json['eval_duration'],
    );
  }

  MessageEntity toEntity() {
    return MessageEntity(Role.system, message?.content ?? '');
  }

  Map<String, dynamic> toJson() {
    return {
      'model': model,
      'created_at': createdAt.toIso8601String(),
      'message': message?.toJson(),
      'done': done,
      'total_duration': totalDuration,
      'load_duration': loadDuration,
      'prompt_eval_count': promptEvalCount,
      'prompt_eval_duration': promptEvalDuration,
      'eval_count': evalCount,
      'eval_duration': evalDuration,
    };
  }
}

class ChatResponseMessage {
  final String role;
  final String content;
  final List<String>? images;

  ChatResponseMessage({
    required this.role,
    required this.content,
    this.images,
  });

  factory ChatResponseMessage.fromJson(Map<String, dynamic> json) {
    return ChatResponseMessage(
      role: json['role'],
      content: json['content'],
      images: json['images'] != null ? List<String>.from(json['images']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'role': role,
      'content': content,
      'images': images,
    };
  }
}
