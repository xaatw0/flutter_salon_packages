class GenerateResponseModel {
  final String model;
  final DateTime createdAt;
  final String? response;
  final bool done;
  final List<int>? context;
  final int? totalDuration;
  final int? loadDuration;
  final int? promptEvalCount;
  final int? promptEvalDuration;
  final int? evalCount;
  final int? evalDuration;
  final String? doneReason;

  GenerateResponseModel({
    required this.model,
    required this.createdAt,
    this.response,
    required this.done,
    this.context,
    this.totalDuration,
    this.loadDuration,
    this.promptEvalCount,
    this.promptEvalDuration,
    this.evalCount,
    this.evalDuration,
    this.doneReason,
  });

  factory GenerateResponseModel.fromJson(Map<String, dynamic> json) {
    return GenerateResponseModel(
      model: json['model'],
      createdAt: DateTime.parse(json['created_at']),
      response: json['response'],
      done: json['done'],
      context: json['context'] != null ? List<int>.from(json['context']) : null,
      totalDuration: json['total_duration'],
      loadDuration: json['load_duration'],
      promptEvalCount: json['prompt_eval_count'],
      promptEvalDuration: json['prompt_eval_duration'],
      evalCount: json['eval_count'],
      evalDuration: json['eval_duration'],
      doneReason: json['done_reason'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'model': model,
      'created_at': createdAt.toIso8601String(),
      'response': response,
      'done': done,
      'context': context,
      'total_duration': totalDuration,
      'load_duration': loadDuration,
      'prompt_eval_count': promptEvalCount,
      'prompt_eval_duration': promptEvalDuration,
      'eval_count': evalCount,
      'eval_duration': evalDuration,
      'done_reason': doneReason,
    };
  }
}
