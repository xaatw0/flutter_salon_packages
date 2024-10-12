class _Details {
  final String parentModel;
  final String format;
  final String family;
  final List<String> families;
  final String parameterSize;
  final String quantizationLevel;

  _Details({
    required this.parentModel,
    required this.format,
    required this.family,
    required this.families,
    required this.parameterSize,
    required this.quantizationLevel,
  });

  factory _Details.fromJson(Map<String, dynamic> json) {
    return _Details(
      parentModel: json['parent_model'] ?? '',
      format: json['format'],
      family: json['family'],
      families: List<String>.from(json['families']),
      parameterSize: json['parameter_size'],
      quantizationLevel: json['quantization_level'],
    );
  }
}

class _ModelInfo {
  final String architecture;
  final int fileType;
  final int parameterCount;
  final int quantizationVersion;
  final int headCount;
  final int headCountKv;
  final double layerNormRmsEpsilon;
  final int blockCount;
  final int contextLength;
  final int embeddingLength;
  final int feedForwardLength;
  final int dimensionCount;
  final int freqBase;
  final int vocabSize;
  final int bosTokenId;
  final int eosTokenId;
  final String model;
  final String pre;

  _ModelInfo({
    required this.architecture,
    required this.fileType,
    required this.parameterCount,
    required this.quantizationVersion,
    required this.headCount,
    required this.headCountKv,
    required this.layerNormRmsEpsilon,
    required this.blockCount,
    required this.contextLength,
    required this.embeddingLength,
    required this.feedForwardLength,
    required this.dimensionCount,
    required this.freqBase,
    required this.vocabSize,
    required this.bosTokenId,
    required this.eosTokenId,
    required this.model,
    required this.pre,
  });

  factory _ModelInfo.fromJson(Map<String, dynamic> json) {
    return _ModelInfo(
      architecture: json['general.architecture'],
      fileType: json['general.file_type'],
      parameterCount: json['general.parameter_count'],
      quantizationVersion: json['general.quantization_version'],
      headCount: json['llama.attention.head_count'],
      headCountKv: json['llama.attention.head_count_kv'],
      layerNormRmsEpsilon: json['llama.attention.layer_norm_rms_epsilon'],
      blockCount: json['llama.block_count'],
      contextLength: json['llama.context_length'],
      embeddingLength: json['llama.embedding_length'],
      feedForwardLength: json['llama.feed_forward_length'],
      dimensionCount: json['llama.rope.dimension_count'],
      freqBase: json['llama.rope.freq_base'],
      vocabSize: json['llama.vocab_size'],
      bosTokenId: json['tokenizer.ggml.bos_token_id'],
      eosTokenId: json['tokenizer.ggml.eos_token_id'],
      model: json['tokenizer.ggml.model'],
      pre: json['tokenizer.ggml.pre'],
    );
  }
}

class ShowResponseData {
  final String modelfile;
  final String parameters;
  final String template;
  final _Details details;
  final _ModelInfo modelInfo;

  ShowResponseData({
    required this.modelfile,
    required this.parameters,
    required this.template,
    required this.details,
    required this.modelInfo,
  });

  factory ShowResponseData.fromJson(Map<String, dynamic> json) {
    return ShowResponseData(
      modelfile: json['modelfile'],
      parameters: json['parameters'],
      template: json['template'],
      details: _Details.fromJson(json['details']),
      modelInfo: _ModelInfo.fromJson(json['model_info']),
    );
  }
}
