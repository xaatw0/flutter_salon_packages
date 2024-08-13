class GenerateResponseEntity {
  String model;
  DateTime createdAt;
  String response;
  bool done;

  GenerateResponseEntity({
    required this.model,
    required this.createdAt,
    required this.response,
    required this.done,
  });

  factory GenerateResponseEntity.fromJson(Map<String, dynamic> json) {
    return GenerateResponseEntity(
      model: json['model'],
      createdAt: DateTime.parse(json['created_at']),
      response: json['response'],
      done: json['done'],
    );
  }
}
