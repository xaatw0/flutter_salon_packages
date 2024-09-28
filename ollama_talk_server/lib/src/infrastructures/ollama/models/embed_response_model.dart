class EmbedResponseModel {
  final String model;
  final List<List<double>> embeddings;
  final int? totalDuration;
  final int? loadDuration;
  final int? promptEvalCount;

  EmbedResponseModel({
    required this.model,
    required this.embeddings,
    this.totalDuration,
    this.loadDuration,
    this.promptEvalCount,
  });

  // fromJson constructor
  factory EmbedResponseModel.fromJson(Map<String, dynamic> json) {
    return EmbedResponseModel(
      model: json['model'],
      embeddings: (json['embeddings'] as List)
          .map((e) => (e as List).map((d) => (d as num).toDouble()).toList())
          .toList(),
      totalDuration: json['total_duration'],
      loadDuration: json['load_duration'],
      promptEvalCount: json['prompt_eval_count'],
    );
  }

  // toJson method
  Map<String, dynamic> toJson() {
    return {
      'model': model,
      'embeddings': embeddings,
      'total_duration': totalDuration,
      'load_duration': loadDuration,
      'prompt_eval_count': promptEvalCount,
    };
  }
}
