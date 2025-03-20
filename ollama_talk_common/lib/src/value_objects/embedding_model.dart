import 'abstract_value_object.dart';

/// A class that provides text embedding models.
class EmbeddingModel extends AbstractValueObject<String> {
  static const kSnowflakeArcticEmbed = EmbeddingModel('snowflake-arctic-embed');

  /// Open-source embedding model by Nomic AI
  static const kNomicEmbedText = EmbeddingModel('nomic-embed-text');

  /// Embedding model by Mixedbread AI
  static const kMxbaiEmbedLarge = EmbeddingModel('mxbai-embed-large');

  ///
  static const kclNagoyaRuriLarge =
      EmbeddingModel('kun432/cl-nagoya-ruri-large:latest', 'ruri-large');

  /// default embedding model
  static const kDefaultModel = kMxbaiEmbedLarge;

  const EmbeddingModel(super._value, [this._alias = null]);

  final String? _alias;

  String get alias => _alias ?? this();
}
