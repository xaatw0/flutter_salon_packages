class LlmModel {
  final String name;
  final DateTime? modifiedAt;
  final int? size;
  final String? digest;
  final ModelDetails? details;

  const LlmModel(
    this.name, {
    this.modifiedAt,
    this.size,
    this.digest,
    this.details,
  });

  factory LlmModel.fromJson(Map<String, dynamic> json) {
    return LlmModel(
      json['name'],
      modifiedAt: DateTime.parse(json['modified_at']),
      size: json['size'] ?? 0,
      digest: json['digest'],
      details: ModelDetails.fromJson(json['details']),
    );
  }

  bool isEmbeddingModel() {
    return name.contains('embed');
  }
}

class ModelDetails {
  final String format;
  final String family;
  final List<String> families;
  final String parameterSize;
  final String quantizationLevel;

  ModelDetails({
    required this.format,
    required this.family,
    required this.families,
    required this.parameterSize,
    required this.quantizationLevel,
  });

  factory ModelDetails.fromJson(Map<String, dynamic> json) {
    return ModelDetails(
      format: json['format'],
      family: json['family'],
      families:
          json['families'] != null ? List<String>.from(json['families']) : [],
      parameterSize: json['parameter_size'],
      quantizationLevel: json['quantization_level'],
    );
  }
}
