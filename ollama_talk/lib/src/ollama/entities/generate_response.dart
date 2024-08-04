class OllamaResponse {
  String model;
  DateTime createdAt;
  String response;
  bool done;

  OllamaResponse({
    required this.model,
    required this.createdAt,
    required this.response,
    required this.done,
  });

  factory OllamaResponse.fromJson(Map<String, dynamic> json) {
    return OllamaResponse(
      model: json['model'],
      createdAt: DateTime.parse(json['created_at']),
      response: json['response'],
      done: json['done'],
    );
  }
}
