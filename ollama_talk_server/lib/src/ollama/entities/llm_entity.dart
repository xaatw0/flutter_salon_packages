import 'package:ollama_talk_common/value_objects.dart';

class LlmEntity implements LlmModel {
  final String name;
  final DateTime modifiedAt;
  final int size;
  final String digest;
  final LlmDetailsEntity details;

  const LlmEntity({
    required this.name,
    required this.modifiedAt,
    required this.size,
    required this.digest,
    required this.details,
  });

  factory LlmEntity.fromJson(Map<String, dynamic> json) {
    return LlmEntity(
      name: json['name'],
      modifiedAt: DateTime.parse(json['modified_at']),
      size: json['size'] ?? 0,
      digest: json['digest'],
      details: LlmDetailsEntity.fromJson(json['details']),
    );
  }

  bool isEmbeddingModel() {
    return name.contains('embed');
  }

  @override
  String call() => name;

  @override
  String toJson() {
    return name;
  }
}

class LlmDetailsEntity {
  final String format;
  final String family;
  final List<String> families;
  final String parameterSize;
  final String quantizationLevel;

  LlmDetailsEntity({
    required this.format,
    required this.family,
    required this.families,
    required this.parameterSize,
    required this.quantizationLevel,
  });

  factory LlmDetailsEntity.fromJson(Map<String, dynamic> json) {
    return LlmDetailsEntity(
      format: json['format'],
      family: json['family'],
      families:
          json['families'] != null ? List<String>.from(json['families']) : [],
      parameterSize: json['parameter_size'],
      quantizationLevel: json['quantization_level'],
    );
  }
}
