import 'dart:async';

import 'package:ollama_talk_common/ollama_talk_common.dart';
import 'package:ollama_talk_server/src/domain/service_locator.dart';

import 'embedding_model.dart';

class OllamaEmbeddingModel implements IEmbeddingModel {
  final EmbeddingModel model;

  const OllamaEmbeddingModel(this.model);

  @override
  Future<List<List<double>>> execute(List<String> messages) {
    final ollamaServer = ServiceLocator.instance.ollamaTalkServer.ollamaServer;
    return ollamaServer
        .embedWithMultipleInput(model(), messages)
        .then((data) => data.embeddings);
  }
}
