import 'package:ollama_talk/ollama_talk.dart';

import 'chat_request.dart';

class ChatResponse {
  final LlmModel model;
  final DateTime createdAt;
  final Message message;
  final bool done;
  final int totalDuration;
  final int loadDuration;
  final int promptEvalCount;
  final int promptEvalDuration;
  final int evalCount;
  final int evalDuration;

  ChatResponse({
    required this.model,
    required this.createdAt,
    required this.message,
    required this.done,
    required this.totalDuration,
    required this.loadDuration,
    required this.promptEvalCount,
    required this.promptEvalDuration,
    required this.evalCount,
    required this.evalDuration,
  });

  factory ChatResponse.fromJson(Map<String, dynamic> json) {
    return ChatResponse(
      model: LlmModel(json['model']),
      createdAt: DateTime.parse(json['created_at']),
      message: Message.fromJson(json['message']),
      done: json['done'],
      totalDuration: json['total_duration'] ?? -1,
      loadDuration: json['load_duration'] ?? -1,
      promptEvalCount: json['prompt_eval_count'] ?? -1,
      promptEvalDuration: json['prompt_eval_duration'] ?? -1,
      evalCount: json['eval_count'] ?? -1,
      evalDuration: json['eval_duration'] ?? -1,
    );
  }
}
