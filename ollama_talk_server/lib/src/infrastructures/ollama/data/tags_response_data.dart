class TagsResponseData {
  final String name;
  final DateTime modifiedAt;
  final int size;
  final String digest;
  final _Details details;

  const TagsResponseData({
    required this.name,
    required this.modifiedAt,
    required this.size,
    required this.digest,
    required this.details,
  });

  factory TagsResponseData.fromJson(Map<String, dynamic> json) {
    return TagsResponseData(
      name: json['name'],
      modifiedAt: DateTime.parse(json['modified_at']),
      size: json['size'] ?? 0,
      digest: json['digest'],
      details: _Details.fromJson(json['details']),
    );
  }

  bool isEmbeddingModel() {
    return name.contains('embed');
  }
}

class _Details {
  final String format;
  final String family;
  final List<String> families;
  final String parameterSize;
  final String quantizationLevel;

  _Details({
    required this.format,
    required this.family,
    required this.families,
    required this.parameterSize,
    required this.quantizationLevel,
  });

  factory _Details.fromJson(Map<String, dynamic> json) {
    return _Details(
      format: json['format'],
      family: json['family'],
      families:
          json['families'] != null ? List<String>.from(json['families']) : [],
      parameterSize: json['parameter_size'],
      quantizationLevel: json['quantization_level'],
    );
  }
}
